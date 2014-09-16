class JenkinsBuildChangeset < ActiveRecord::Base
  unloadable

  ## Relations
  belongs_to :jenkins_build
  belongs_to :repository

  ## Validations
  validates :jenkins_build_id, presence: true
  validates :repository_id,    presence: true
  validates :revision,         presence: true, uniqueness: { scope: :jenkins_build_id }
end
