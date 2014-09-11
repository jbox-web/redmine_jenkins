class BuildManager

  def initialize(job)
    @job    = job
    @data   = @job.update_status
    @client = @job.jenkins_client
  end


  def create_builds
    do_create_builds(@data['builds'].take(@job.builds_to_keep))
    @job.update_status
  end


  def update_all_builds
    do_create_builds(@data['builds'].take(@job.builds_to_keep), true)
  end


  def update_last_build
    if @data['builds'].any?
      last_build = [@data['builds'].first]
    else
      last_build = []
    end

    do_create_builds(last_build, true)
  end


  private


    def do_create_builds(builds, update = false)
      builds.each do |build_data|

        ## Find Build in Redmine
        build = JenkinsBuild.find_by_jenkins_job_id_and_number(@job.id, build_data['number'])

        if build.nil?
          ## Get BuildDetails from Jenkins
          build_details = @client.job.get_build_details(@job.name, build_data['number'])
          build = JenkinsBuild.new
          build.jenkins_job_id = @job.id

          build.number      = build_data['number']
          build.result      = build_details['result'].nil? ? 'running' : build_details['result']
          build.building    = build_details['building']
          build.duration    = build_details['duration']
          build.finished_at = Time.at(build_details['timestamp'].to_f / 1000)
          build.save!

          create_changeset(build, build_details['changeSet']['items'])
        elsif update
          build_details     = @client.job.get_build_details(@job.name, build_data['number'])

          build.result      = build_details['result'].nil? ? 'running' : build_details['result']
          build.building    = build_details['building']
          build.duration    = build_details['duration']
          build.finished_at = Time.at(build_details['timestamp'].to_f / 1000)
          build.save!

          create_changeset(build, build_details['changeSet']['items'])
        end

        if @job.builds.size > @job.builds_to_keep
          @job.builds.last.destroy
        end
      end

      return true
    end


    def create_changeset(build, changesets)
      changesets.each do |changeset|
        build_changeset = JenkinsBuildChangeset.find_by_jenkins_build_id_and_revision(build.id, changeset['commitId'])

        if build_changeset.nil?
          build_changeset = JenkinsBuildChangeset.new(:jenkins_build_id => build.id,
                                                      :repository_id    => @job.repository_id,
                                                      :revision         => changeset['commitId'],
                                                      :comment          => changeset['comment'])
          build_changeset.save!
        end
      end
    end

end
