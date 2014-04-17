class JenkinsTestResult < ActiveRecord::Base
  unloadable

  belongs_to :jenkins_build

  validates_presence_of   :jenkins_build_id
  validates_uniqueness_of :jenkins_build_id

  def description_for_activity
    return "TestResults: #{fail_count}Failed #{skip_count}Skipped Total-#{total_count}"
  end

end
