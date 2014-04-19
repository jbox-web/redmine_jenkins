class JenkinsBuildChangeset < ActiveRecord::Base
  unloadable

  ## Relations
  belongs_to :jenkins_build

  ## Validations
  validates_presence_of   :jenkins_build_id, :revision
  validates_uniqueness_of :revision, :scope => :jenkins_build_id
end
