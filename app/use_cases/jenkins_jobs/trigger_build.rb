module JenkinsJobs
  class TriggerBuild < Base

    def execute
      build_number = ''
      opts = {}
      opts['build_start_timeout'] = 30 if jenkins_job.wait_for_build_id

      begin
        build_number = jenkins_client.job.build(jenkins_job.name, {}, opts)
      rescue => e
        @errors << e.message
      else
        jenkins_job.latest_build_number = build_number if jenkins_job.wait_for_build_id
        jenkins_job.state = 'running'
        jenkins_job.save!
      end
    end

  end
end
