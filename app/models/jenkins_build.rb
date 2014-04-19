class JenkinsBuild < ActiveRecord::Base
  unloadable

  ## Relations
  belongs_to :jenkins_job
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  has_many   :jenkins_build_changesets, :dependent => :destroy

  ## Validations
  validates_presence_of :jenkins_job_id, :number
  validates_uniqueness_of :number, :scope => :jenkins_job_id

  ## Scopes
  default_scope :order => 'number DESC'

  ## Redmine Events
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


  def self.find_by_changeset(changeset)
    retval = JenkinsBuild.find(:all,
                              :order      => "#{JenkinsBuild.table_name}.number",
                              :conditions => ["#{JenkinsBuildChangeset.table_name}.repository_id = ? and #{JenkinsBuildChangeset.table_name}.revision = ?", changeset.repository_id, changeset.revision],
                              :joins      => "INNER JOIN #{JenkinsBuildChangeset.table_name} ON #{JenkinsBuildChangeset.table_name}.jenkins_build_id = #{JenkinsBuild.table_name}.id")
    return retval
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
      desc << self.jenkins_job.health_report.map{|health_report| health_report['description']}.join("\n")
    end

    return desc
  end


  def url
    return "#{self.jenkins_job.jenkins_setting.url}/job/#{self.jenkins_job.name}/#{self.number}"
  end

end
