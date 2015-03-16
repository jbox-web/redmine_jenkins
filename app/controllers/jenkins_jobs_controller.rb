class JenkinsJobsController < ApplicationController
  unloadable

  # Redmine ApplicationController method
  before_filter :find_project_by_project_id

  before_filter :can_build_jenkins_jobs, only:   [:build]
  before_filter :find_job,               except: [:index, :new, :create]

  layout Proc.new { |controller| controller.request.xhr? ? false : 'base' }

  helper :redmine_bootstrap_kit
  helper :jenkins


  def show
    render_404
  end


  def new
    @job  = @project.jenkins_jobs.new
    @jobs = available_jobs
  end


  def create
    @job = @project.jenkins_jobs.new(params[:jenkins_jobs])
    if @job.save
      flash[:notice] = l(:notice_job_added)
      result = BuildManager.create_builds!(@job)
      flash[:error] = result.message_on_errors if !result.success?
      render_js_redirect
    else
      @jobs = available_jobs
    end
  end


  def edit
    @jobs = @project.jenkins_setting.get_jobs_list
  end


  def update
    if @job.update_attributes(params[:jenkins_jobs])
      flash[:notice] = l(:notice_job_updated)
      result = BuildManager.update_all_builds!(@job)
      flash[:error] = result.message_on_errors if !result.success?
      render_js_redirect
    else
      @jobs = available_jobs
    end
  end


  def destroy
    flash[:notice] = l(:notice_job_deleted) if @job.destroy
    render_js_redirect
  end


  def build
    result = BuildManager.trigger_build!(@job)
    if result.success?
      flash.now[:notice] = result.message_on_success
    else
      flash.now[:error] = result.message_on_errors
    end
  end


  def history
    @builds = @job.builds.ordered.paginate(page: params[:page], per_page: 5)
  end


  def console
    @console_output = @job.console
  end


  def refresh
    result = BuildManager.update_last_build!(@job)
    flash.now[:error] = result.message_on_errors if !result.success?
  end


  private


    def can_build_jenkins_jobs
      render_403 unless User.current.allowed_to?(:build_jenkins_jobs, @project)
    end


    def find_job
      @job = @project.jenkins_jobs.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      render_404
    end


    def success_url
      settings_project_path(@project, 'jenkins')
    end


    def render_js_redirect
      respond_to do |format|
        format.js { render js: "window.location = #{success_url.to_json};" }
      end
    end


    def available_jobs
      @project.jenkins_setting.get_jobs_list - @project.jenkins_jobs.map(&:name)
    end

end
