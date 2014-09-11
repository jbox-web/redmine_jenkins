class JenkinsJob < ActiveRecord::Base
  unloadable

  ## Relations
  belongs_to :project
  belongs_to :repository
  belongs_to :jenkins_setting
  has_many   :builds, dependent: :destroy, class_name: 'JenkinsBuild'

  ## Validations
  validates_presence_of   :project_id, :repository_id, :jenkins_setting_id, :name
  validates_uniqueness_of :name, :scope => :jenkins_setting_id

  ## Serialization
  serialize :health_report, Array

  ## Delegate
  delegate :jenkins_client, :wait_for_build_id, to: :jenkins_setting


  def url
    return "#{self.jenkins_setting.url}/job/#{self.name}"
  end


  def latest_build_url
    return "#{self.jenkins_setting.url}/job/#{self.name}/#{self.latest_build_number}"
  end


  def update_status
    job_data = jenkins_client.job.list_details(self.name)

    self.state = color_to_state(job_data['color']) || state
    self.description = job_data['description'] || ''
    self.health_report = job_data['healthReport']
    self.latest_build_number   = !job_data['lastBuild'].nil? ? job_data['lastBuild']['number'] : 0
    self.latest_build_date     = self.builds.first.finished_at rescue ''
    self.latest_build_duration = self.builds.first.duration rescue ''
    self.save!
    self.reload
    return job_data
  end


  def build
    build_number = ""
    opts = {}
    opts['build_start_timeout'] = 30 if wait_for_build_id

    begin
      build_number = jenkins_client.job.build(name, {}, opts)
    rescue => e
      error   = true
      content = e.message
    else
      error = false
    end

    if !error
      if wait_for_build_id
        self.latest_build_number = build_number
        content = l(:label_build_accepted, :job_name => self.name, :build_id => ": '#{build_number}'")
      else
        content = l(:label_build_accepted, :job_name => self.name, :build_id => '')
      end

      self.state = 'running'
      self.save!
      self.reload
    end

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
      when 'red_anime'
        state = 'running'
    end
    return state
  end

end
