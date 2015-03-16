class ChangesetsJenkinsBuild < ActiveRecord::Base
  unloadable

  ## Relations
  belongs_to :changeset
  belongs_to :jenkins_build

  ## Delegators
  delegate :revision, to: :changeset

end
