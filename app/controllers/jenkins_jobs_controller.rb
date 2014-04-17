class JenkinsJobsController < JenkinsController
  unloadable

  before_filter :can_build_jenkins_jobs, :only => [:build]
  before_filter :find_job,               :only => [:build, :history, :console, :refresh]


  def build
    build_number = ""

    begin
      if @jenkins_setting.wait_for_build_id
        opts = {'build_start_timeout' => 30}
      else
        opts = {}
      end
      build_number = @jenkins_setting.jenkins_client.job.build(@job.name, {}, opts)
    rescue => e
      @error   = true
      @content = e.message
    else
      @error = false
    end

    if @jenkins_setting.wait_for_build_id
      @job.latest_build_number = build_number
      @content = l(:label_build_accepted, :job_name => @job.name, :build_id => ": '#{build_number}'")
    else
      @content = l(:label_build_accepted, :job_name => @job.name, :build_id => '')
    end

    @job.state = 'running'
    @job.save!
  end


  def history
    @jenkins_builds = @job.jenkins_builds.paginate(:page => params[:page], :per_page => 5)
  end


  def console
    begin
      @console_output = @jenkins_setting.jenkins_client.job.get_console_output(@job.name, @job.latest_build_number)['output'].gsub('\r\n', '<br />')
    rescue JenkinsApi::Exceptions::NotFound => e
      @console_output = e.message
    end
  end


  def refresh
    @jenkins_setting.update_job(@job)
    @job.reload
  end


  private


  def can_build_jenkins_jobs
    render_403 unless view_context.user_allowed_to(:build_jenkins_jobs, @project)
  end


  def find_job
    @job = JenkinsJob.find_by_id(params[:job_id])
  end

end
