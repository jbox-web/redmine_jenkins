class JenkinsJob < ActiveRecord::Base
  unloadable

  ## Relations
  belongs_to :project
  belongs_to :repository
  belongs_to :jenkins_setting
  has_many   :jenkins_builds, :dependent => :destroy

  ## Validations
  validates_presence_of   :project_id, :repository_id, :jenkins_setting_id, :name
  validates_uniqueness_of :name, :scope => :jenkins_setting_id

  ## Serialization
  serialize :health_report, Array

  ## Callbacks
  after_create :create_job_builds


  def url
    return "#{self.jenkins_setting.url}/job/#{self.name}"
  end


  def latest_build_url
    return "#{self.jenkins_setting.url}/job/#{self.name}/#{self.latest_build_number}"
  end


  def create_job_builds
    job_data = update_status
    create_builds(job_data['builds'])
    update_status
  end


  def update_all_builds
    job_data = update_status
    create_builds(job_data['builds'], true)
  end


  def update_last_build
    job_data = update_status
    create_builds([job_data['builds'].first], true)
  end


  def update_status
    job_data = jenkins_client.job.list_details(self.name)

    self.state = color_to_state(job_data['color'])
    self.description = job_data['description'] || ''
    self.health_report = job_data['healthReport']
    self.latest_build_number   = !job_data['lastBuild'].nil? ? job_data['lastBuild']['number'] : 0
    self.latest_build_date     = self.jenkins_builds.first.finished_at rescue ''
    self.latest_build_duration = self.jenkins_builds.first.duration rescue ''
    self.save!(:validate => false)
    self.reload
    return job_data
  end


  def build
    build_number = ""

    begin
      if self.jenkins_setting.wait_for_build_id
        opts = {'build_start_timeout' => 30}
      else
        opts = {}
      end
      build_number = jenkins_client.job.build(self.name, {}, opts)
    rescue => e
      error   = true
      content = e.message
    else
      error = false
    end

    if self.jenkins_setting.wait_for_build_id
      self.latest_build_number = build_number
      content = l(:label_build_accepted, :job_name => self.name, :build_id => ": '#{build_number}'")
    else
      content = l(:label_build_accepted, :job_name => self.name, :build_id => '')
    end

    self.state = 'running'
    self.save!

    return error, content
  end


  def console
    begin
      console_output = jenkins_client.job.get_console_output(self.name, self.latest_build_number)['output'].gsub('\r\n', '<br />')
    rescue JenkinsApi::Exceptions::NotFound => e
      console_output = e.message
    end
    return console_output
  end


  private


  def jenkins_client
    self.jenkins_setting.jenkins_client
  end


  def create_builds(builds, update = false)
    builds.each do |build_data|
      ## Find Build in Redmine
      build = JenkinsBuild.find_by_jenkins_job_id_and_number(self.id, build_data['number'])

      if build.nil?
        ## Get BuildDetails from Jenkins
        build_details = jenkins_client.job.get_build_details(self.name, build_data['number'])
        build = JenkinsBuild.new
        build.jenkins_job_id = self.id

        build.number      = build_data['number']
        build.result      = build_details['result'].nil? ? 'running' : build_details['result']
        build.building    = build_details['building']
        build.duration    = build_details['duration']
        build.finished_at = Time.at(build_details['timestamp'].to_f / 1000)
        build.save!

        create_changeset(build, build_details['changeSet']['items'])
      elsif update
        build_details     = jenkins_client.job.get_build_details(self.name, build_data['number'])

        build.result      = build_details['result'].nil? ? 'running' : build_details['result']
        build.building    = build_details['building']
        build.duration    = build_details['duration']
        build.finished_at = Time.at(build_details['timestamp'].to_f / 1000)
        build.save!

        create_changeset(build, build_details['changeSet']['items'])
      end
    end
    return true
  end


  def create_changeset(build, changesets)
    changesets.each do |changeset|
      build_changeset = JenkinsBuildChangeset.find_by_jenkins_build_id_and_revision(build.id, changeset['commitId'])

      if build_changeset.nil?
        build_changeset = JenkinsBuildChangeset.new(:jenkins_build_id => build.id,
                                                    :repository_id    => self.repository_id,
                                                    :revision         => changeset['commitId'],
                                                    :comment          => changeset['comment'])
        build_changeset.save!
      end
    end
  end


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

end
