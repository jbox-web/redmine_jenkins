module BuildManager
  class << self

    def create_builds!(job)
      JenkinsJobs::CreateBuilds.new(job).call
    end


    def update_all_builds!(job)
      JenkinsJobs::UpdateAllBuilds.new(job).call
    end


    def update_last_build!(job)
      JenkinsJobs::UpdateLastBuild.new(job).call
    end


    def trigger_build!(job)
      JenkinsJobs::TriggerBuild.new(job).call
    end

  end
end
