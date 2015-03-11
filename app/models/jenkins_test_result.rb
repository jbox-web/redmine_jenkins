class JenkinsTestResult < ActiveRecord::Base
  unloadable

  belongs_to :jenkins_build
  validates :jenkins_build_id, presence: true, uniqueness: true


  def description_for_activity
    return "TestResults: #{fail_count}Failed #{skip_count}Skipped Total-#{total_count}"
  end

end
