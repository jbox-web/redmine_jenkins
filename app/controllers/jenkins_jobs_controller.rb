class JenkinsJobsController < ApplicationController
  unloadable

  before_filter :find_project
  before_filter :check_xhr_request

  before_filter :can_build_jenkins_jobs, :only => [:build]
  before_filter :find_job,               :except => [:index, :new, :create]

  layout Proc.new { |controller| controller.request.xhr? ? 'popup' : 'base' }

  helper :jenkins


  def show
    render_404
  end


  def new
    @job = JenkinsJob.new()
    @jobs = @jenkins_setting.get_jobs_list - @jenkins_setting.jobs.map(&:name)
  end


  def create
    @job = JenkinsJob.new(params[:jenkins_jobs])
    @job.project = @project
    @job.jenkins_setting = @jenkins_setting

    respond_to do |format|
      if @job.save
        flash[:notice] = l(:notice_job_added)
        BuildManager.new(@job).create_builds

        format.html { redirect_to success_url }
        format.js   { render :js => "window.location = #{success_url.to_json};" }
      else
        format.html {
          flash[:error] = l(:notice_job_add_failed)
          render :action => "create"
        }
        format.js { render "form_error", :layout => false }
      end
    end
  end


  def edit
    @jobs = @jenkins_setting.get_jobs_list
  end


  def update
    respond_to do |format|
      if @job.update_attributes(params[:jenkins_jobs])
        flash[:notice] = l(:notice_job_updated)

        manager = BuildManager.new(@job)
        if !manager.update_all_builds
          flash[:error] = "#{l(:error_jenkins_connection)} : #{manager.errors.join(', ')}"
        end

        format.html { redirect_to success_url }
        format.js   { render :js => "window.location = #{success_url.to_json};" }
      else
        format.html {
          flash[:error] = l(:notice_job_update_failed)
          render :action => "edit"
        }
        format.js { render "form_error", :layout => false }
      end
    end
  end


  def destroy
    respond_to do |format|
      if @job.destroy
        flash[:notice] = l(:notice_job_deleted)
        format.js { render :js => "window.location = #{success_url.to_json};" }
      else
        format.js { render :layout => false }
      end
    end
  end


  def build
    @error, @content = @job.build
  end


  def history
    @builds = @job.builds.paginate(:page => params[:page], :per_page => 5)
  end


  def console
    @console_output = @job.console
  end


  def refresh
    manager = BuildManager.new(@job)
    if !manager.update_last_build
      @errors = "#{l(:error_jenkins_connection)} : #{manager.errors.join(', ')}"
    else
      @errors = ''
    end
  end


  private


  def can_build_jenkins_jobs
    render_403 unless view_context.user_allowed_to(:build_jenkins_jobs, @project)
  end


  def find_job
    @job = JenkinsJob.find_by_id(params[:id])
    if @job.nil?
      render_404
    end
  end


  def find_project
    @project = Project.find(params[:project_id])
    if @project.nil?
      render_404
    end

    @jenkins_setting = @project.jenkins_setting
  end


  def check_xhr_request
    @is_xhr ||= request.xhr?
  end


  def success_url
    url_for(:controller => 'projects', :action => 'settings', :id => @project, :tab => 'jenkins')
  end

end
