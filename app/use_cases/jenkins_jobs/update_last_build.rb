module JenkinsJobs
  class UpdateLastBuild < Base

    def execute
      return if !job_status_updated?
      last_build = job_data['builds'].any? ? [job_data['builds'].first] : []
      do_create_builds(last_build, true)
    end

  end
end
