require 'jenkins_api_client'

class JenkinsSetting < ActiveRecord::Base
  unloadable

  ## Relations
  belongs_to :project
  has_many   :jenkins_jobs, :dependent => :destroy

  ## Validations
  validates_presence_of   :project_id, :url
  validates_uniqueness_of :project_id

  ## Callbacks
  after_save :update_all_jobs_build


  def jenkins_client
    options = {}
    options[:server_url] = self.url
    options[:http_open_timeout] = 5
    options[:http_read_timeout] = 60
    options[:username] = self.auth_user if !self.auth_user.empty?
    options[:password] = self.auth_password if !self.auth_password.empty?

    @jenkins_client ||= JenkinsApi::Client.new(options)
  end


  def get_jenkins_version
    begin
      output = jenkins_client.get_jenkins_version
      error  = false
    rescue => e
      output = e.message
      error  = true
    end
    return error, output
  end


  def get_jobs_list
    begin
      jenkins_client.job.list_all
    rescue Net::OpenTimeout => e
      []
    end
  end


  def update_jobs_status
    self.jenkins_jobs.each do |job|
      job.update_status
    end
  end


  def update_jobs_build
    self.jenkins_jobs.each do |job|
      job.update_last_build
    end
  end


  def update_all_jobs_build
    self.jenkins_jobs.each do |job|
      job.update_all_builds
    end
  end


  def jenkins_count_of(job_name)
    jenkins_client.job.list_details(job_name)['builds'].size
  end

end
