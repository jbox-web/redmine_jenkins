class JenkinsBuild < ActiveRecord::Base
  unloadable

  belongs_to :jenkins_job, :class_name => 'JenkinsJob', :foreign_key => 'jenkins_job_id'
  belongs_to :author,      :class_name => 'User',       :foreign_key => 'author_id'

  validates_presence_of :jenkins_job_id, :number

  validates_uniqueness_of :number, :scope => :jenkins_job_id

  default_scope :order => 'number DESC'

  acts_as_event :datetime    => :finished_at,
                :title       => :event_name,
                :description => :event_desc,
                :author      => :author,
                :url         => :event_url,
                :type        => 'build_activity'

  acts_as_activity_provider :type         => 'build_activity',
                            :permission   => :view_build_activity,
                            :timestamp    => "#{table_name}.finished_at",
                            :author_key   => :author_id,
                            :find_options => {:include => {:jenkins_job => :project}}


  def self.redmine_count_of(job_name)
    job = JenkinsJob.find_by_name(job_name)
    return 0 if job.nil?
    return JenkinsBuild.find_all_by_jenkins_job_id(job.id).count
  end


  def project
    return self.jenkins_job.project
  end


  def event_name
    return "#{l(:label_build)} #{self.jenkins_job.name} ##{self.number} : #{self.result.capitalize}"
  end


  def event_url
    return url
  end


  def event_desc
    desc = ""
    if self.jenkins_job.health_report.any?
      self.jenkins_job.health_report.each do |health_report|
        desc << "#{health_report['description']}\n"
      end
    end

    return desc
  end


  def url
    return "#{self.jenkins_job.jenkins_setting.url}/job/#{self.jenkins_job.name}/#{self.number}"
  end

end
