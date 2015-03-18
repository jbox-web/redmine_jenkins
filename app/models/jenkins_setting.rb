class JenkinsSetting < ActiveRecord::Base
  unloadable

  ## Relations
  belongs_to :project

  attr_accessible :url, :auth_user, :auth_password, :show_compact, :wait_for_build_id

  ## Validations
  validates :project_id, presence: true, uniqueness: true
  validates :url,        presence: true


  def jenkins_connection
    jenkins_client.connection
  end


  def test_connection
    jenkins_client.test_connection
  end


  def get_jobs_list
    jenkins_client.get_jobs_list
  end


  def number_of_builds_for(job_name)
    jenkins_client.number_of_builds_for(job_name)
  end


  private


    def jenkins_client
      @jenkins_client ||= JenkinsClient.new(url, jenkins_options)
    end


    def jenkins_options
      options = {}
      options[:username] = auth_user if !auth_user.empty?
      options[:password] = auth_password if !auth_password.empty?
      options
    end

end
