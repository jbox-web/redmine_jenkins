class JenkinsJob < ActiveRecord::Base
  unloadable

  belongs_to :project,         :foreign_key => 'project_id'
  belongs_to :jenkins_setting, :foreign_key => 'jenkins_setting_id', :class_name => 'JenkinsSetting'
  has_many   :jenkins_builds,  :foreign_key => 'jenkins_job_id',     :dependent  => :destroy

  serialize :health_report, Array

  validates_presence_of :project_id, :jenkins_setting_id, :name


  def url
    return "#{self.jenkins_setting.url}/job/#{self.name}"
  end


  def latest_build_url
    return "#{self.jenkins_setting.url}/job/#{self.name}/#{self.latest_build_number}"
  end

end
