module JenkinsJobs
  class CreateBuilds < Base

    def execute
      return if !job_status_updated?
      do_create_builds(job_data['builds'].take(jenkins_job.builds_to_keep))
    end

  end
end
