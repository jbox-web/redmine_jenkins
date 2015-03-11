class JenkinsBuild < ActiveRecord::Base
  unloadable

  ## Relations
  belongs_to :jenkins_job
  belongs_to :author,     class_name: 'User', foreign_key: 'author_id'
  has_many   :changesets, class_name: 'JenkinsBuildChangeset', dependent: :destroy

  ## Validations
  validates :jenkins_job_id,  presence: true
  validates :author_id,       presence: true
  validates :number,          presence: true, uniqueness: { scope: :jenkins_job_id }

  ## Delegators
  delegate :project, to: :jenkins_job

  ## Scopes
  scope :ordered, -> { order('number DESC')  }

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


  class << self

    def redmine_count_of(job_name)
      job = JenkinsJob.find_by_name(job_name)
      return 0 if job.nil?
      return JenkinsBuild.find_all_by_jenkins_job_id(job.id).count
    end


    def find_by_changeset(changeset)
      retval = JenkinsBuild.find(:all,
                                :order      => "#{JenkinsBuild.table_name}.number",
                                :conditions => ["#{JenkinsBuildChangeset.table_name}.repository_id = ? and #{JenkinsBuildChangeset.table_name}.revision = ?", changeset.repository_id, changeset.revision],
                                :joins      => "INNER JOIN #{JenkinsBuildChangeset.table_name} ON #{JenkinsBuildChangeset.table_name}.jenkins_build_id = #{JenkinsBuild.table_name}.id")
      return retval
    end

  end


  def url
    "#{jenkins_job.url}/#{number}"
  end


  def event_url(options = {})
    url
  end


  def event_name
    "#{l(:label_build)} #{jenkins_job.name} ##{number} : #{result.capitalize}"
  end


  def event_desc
    desc = ""

    if jenkins_job.health_report.any?
      desc << jenkins_job.health_report.map{|health_report| health_report['description']}.join("\n")
    end

    return desc
  end

end
