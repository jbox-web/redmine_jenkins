class JenkinsJob < ActiveRecord::Base
  unloadable

  ## Relations
  belongs_to :project
  belongs_to :repository
  belongs_to :jenkins_setting
  has_many   :builds, class_name: 'JenkinsBuild', dependent: :destroy

  ## Validations
  validates :project_id,         presence: true
  validates :repository_id,      presence: true
  validates :jenkins_setting_id, presence: true
  validates :name,               presence: true, uniqueness: { scope: :jenkins_setting_id }

  ## Serializations
  serialize :health_report, Array

  ## Delegators
  delegate :jenkins_connection, :wait_for_build_id, to: :jenkins_setting


  def url
    "#{jenkins_setting.url}/job/#{name}"
  end


  def latest_build_url
    "#{url}/#{latest_build_number}"
  end


  def build
    build_number = ""
    opts = {}
    opts['build_start_timeout'] = 30 if wait_for_build_id

    begin
      build_number = jenkins_connection.job.build(name, {}, opts)
    rescue => e
      error   = true
      content = "#{l(:error_jenkins_connection)} : #{e.message}"
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
      console_output = jenkins_connection.job.get_console_output(name, latest_build_number)['output'].gsub('\r\n', '<br />')
    rescue => e
      console_output = e.message
    end
    return console_output
  end

end
