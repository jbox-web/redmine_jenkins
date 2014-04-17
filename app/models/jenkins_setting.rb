require 'jenkins_api_client'

class JenkinsSetting < ActiveRecord::Base
  unloadable

  belongs_to :project

  serialize :job_filter, Array

  validates_presence_of :project_id, :url

  validates_uniqueness_of :project_id

  after_commit ->(obj) { obj.create_jobs }, on: :update


  def job_include?(job)
    return false if self.job_filter.nil?
    return self.job_filter.include?(job)
  end


  def jenkins_client
    @jenkins_client ||= JenkinsApi::Client.new({:server_url  => self.url,
                                               :username     => self.auth_user,
                                               :password     => self.auth_password,
                                               :open_timeout => 5,
                                               :read_timeout => 60})
  end


  def get_jobs_list
    begin
      jenkins_client.job.list_all
    rescue Net::OpenTimeout => e
      []
    end
  end


  def update_jobs
    self.job_filter.each do |job_name|
      create_or_update_job(job_name)
    end
  end


  def update_job(job)
    job_data = jenkins_client.job.list_details(job.name)
    last_build = job_data['builds'].first

    job.latest_build_number = last_build['number']
    job.state = color_to_state(job_data['color'])
    job.save!

    builds = [last_build]
    create_builds(job, builds, true)
  end


  def jenkins_count_of(job_name)
    jenkins_client.job.list_details(job_name)['builds'].size
  end


  protected


  ## When settings are saved, create new jobs and delete old ones
  def create_jobs
    jobs = JenkinsJob.find_all_by_project_id(self.project.id)
    jobs.each do |job|
      next if self.job_include?(job.name)
      job.destroy
    end

    self.job_filter.each do |job_name|
      create_or_update_job(job_name)
    end
  end


  private


  def color_to_state(color)
    state = ''
    case color
      when 'blue'
        state = 'success'
      when 'red'
        state = 'failure'
      when 'notbuilt'
        state = 'notbuilt'
      when 'blue_anime'
        state = 'running'
    end
    return state
  end


  def create_or_update_job(job_name)
    job = JenkinsJob.find_by_jenkins_setting_id_and_name(self.id, job_name)
    job_data = jenkins_client.job.list_details(job_name)

    if job.nil?
      job = JenkinsJob.new
      job.project_id = self.project.id
      job.jenkins_setting_id = self.id
      job.name = job_name
    end

    job.state = color_to_state(job_data['color'])
    job.description = job_data['description'] || ''
    job.health_report = job_data['healthReport']
    job.latest_build_number = !job_data['lastBuild'].nil? ? job_data['lastBuild']['number'] : 0
    job.save!

    create_builds(job, job_data['builds'])
  end


  def create_builds(job, builds, update = false)
    builds.each do |build_data|
      ## Find Build in Redmine
      build = JenkinsBuild.find_by_jenkins_job_id_and_number(job.id, build_data['number'])

      if build.nil?
        ## Get BuildDetails from Jenkins
        build_details = jenkins_client.job.get_build_details(job.name, build_data['number'])
        build = JenkinsBuild.new
        build.jenkins_job_id = job.id

        build.number      = build_data['number']
        build.result      = build_details['result'].nil? ? 'running' : build_details['result']
        build.building    = build_details['building']
        build.finished_at = Time.at(build_details['timestamp'].to_f / 1000)
        build.save!
      elsif update
        build_details     = jenkins_client.job.get_build_details(job.name, build_data['number'])
        build.result      = build_details['result'].nil? ? 'running' : build_details['result']
        build.building    = build_details['building']
        build.finished_at = Time.at(build_details['timestamp'].to_f / 1000)
        build.save!
      end
    end

    return true
  end

end
