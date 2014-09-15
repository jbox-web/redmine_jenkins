class JenkinsSetting < ActiveRecord::Base
  unloadable

  ## Relations
  belongs_to :project
  has_many   :jobs, dependent: :destroy, class_name: 'JenkinsJob'

  ## Validations
  validates_presence_of   :project_id, :url
  validates_uniqueness_of :project_id


  def jenkins_connection
    jenkins_client.connection
  end


  def test_connection
    test_data = jenkins_client.test_connection
  end


  def get_jobs_list
    begin
      jenkins_connection.job.list_all
    rescue => e
      []
    end
  end


  def update_jobs_status
    jobs.each do |job|
      job.update_status
    end
  end


  def jenkins_count_of(job_name)
    jenkins_connection.job.list_details(job_name)['builds'].size rescue 0
  end


  private


    def jenkins_client
      @jenkins_client ||= JenkinsClient.new(self.url, jenkins_options)
    end


    def jenkins_options
      options = {}
      options[:username] = self.auth_user if !self.auth_user.empty?
      options[:password] = self.auth_password if !self.auth_password.empty?
      options
    end

end
