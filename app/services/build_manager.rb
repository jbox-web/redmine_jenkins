class BuildManager

  attr_reader :data
  attr_reader :errors


  def initialize(job)
    @job    = job
    @client = @job.jenkins_connection
    @errors = []
  end


  def create_builds
    if job_status_updated?
      do_create_builds(data['builds'].take(@job.builds_to_keep))
      job_status_updated?
    else
      return false
    end
  end


  def update_all_builds
    if job_status_updated?
      do_create_builds(data['builds'].take(@job.builds_to_keep), true)
    else
      return false
    end
  end


  def update_last_build
    if job_status_updated?
      if data['builds'].any?
        last_build = [data['builds'].first]
      else
        last_build = []
      end

      do_create_builds(last_build, true)
    else
      return false
    end
  end


  private


    def job_status_updated?
      begin
        @data = @client.job.list_details(@job.name)
      rescue => e
        @errors << e.message
        return false
      else
        @job.state                 = color_to_state(data['color']) || @job.state
        @job.description           = data['description'] || ''
        @job.health_report         = data['healthReport']
        @job.latest_build_number   = !data['lastBuild'].nil? ? data['lastBuild']['number'] : 0
        @job.latest_build_date     = @job.builds.first.finished_at rescue ''
        @job.latest_build_duration = @job.builds.first.duration rescue ''
        @job.save!
        @job.reload
        return true
      end
    end


    def color_to_state(color)
      state = ''
      case color
        when 'blue'
          state = 'success'
        when 'red'
          state = 'failure'
        when 'notbuilt'
          state = 'notbuilt'
        when 'blue_anime'
          state = 'running'
        when 'red_anime'
          state = 'running'
      end
      return state
    end


    def do_create_builds(builds, update = false)
      builds.each do |build_data|

        ## Find Build in Redmine
        build = JenkinsBuild.find_by_jenkins_job_id_and_number(@job.id, build_data['number'])

        if build.nil?
          ## Get BuildDetails from Jenkins
          build_details     = get_build_details(@job.name, build_data['number'])

          ## Create a new AR object to store data
          build = JenkinsBuild.new
          build.jenkins_job_id = @job.id

          build.number      = build_data['number']
          build.result      = build_details['result'].nil? ? 'running' : build_details['result']
          build.building    = build_details['building']
          build.duration    = build_details['duration']
          build.finished_at = Time.at(build_details['timestamp'].to_f / 1000)
          build.author      = User.current
          build.save!

          create_changeset(build, build_details['changeSet']['items'])
        elsif update
          ## Get BuildDetails from Jenkins
          build_details     = get_build_details(@job.name, build_data['number'])

          ## Update the AR object with new data
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

      if @job.builds.size > @job.builds_to_keep
        @job.builds.last(@job.builds.size - @job.builds_to_keep).map(&:destroy)
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


    def get_build_details(job_name, build_number)
      @client.job.get_build_details(job_name, build_number)
    end

end
