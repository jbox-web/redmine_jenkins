module JenkinsJobs
  class UpdateAllBuilds < Base

    def execute
      return if !job_status_updated?
      do_create_builds(job_data['builds'].take(jenkins_job.builds_to_keep), true)
    end

  end
end
