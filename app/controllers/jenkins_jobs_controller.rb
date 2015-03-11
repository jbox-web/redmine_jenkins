class JenkinsJobsController < ApplicationController
  unloadable

  # Redmine ApplicationController method
  before_filter :find_project_by_project_id

  before_filter :check_xhr_request

  before_filter :can_build_jenkins_jobs, only:   [:build]
  before_filter :find_job,               except: [:index, :new, :create]

  layout Proc.new { |controller| controller.request.xhr? ? false : 'base' }

  helper :jenkins


  def show
    render_404
  end


  def new
    @job  = @project.jenkins_jobs.new
    @jobs = @project.jenkins_setting.get_jobs_list - @project.jenkins_jobs.map(&:name)
  end


  def create
    @job = @project.jenkins_jobs.new(params[:jenkins_jobs])

    respond_to do |format|
      if @job.save
        flash[:notice] = l(:notice_job_added)
        BuildManager.new(@job).create_builds

        format.html { redirect_to success_url }
        format.js   { render :js => "window.location = #{success_url.to_json};" }
      else
        format.html {
          flash[:error] = l(:notice_job_add_failed)
          render action: 'new'
        }
        format.js { render 'form_error', layout: false }
      end
    end
  end


  def edit
    @jobs = @project.jenkins_setting.get_jobs_list
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
    flash[:notice] = l(:notice_job_deleted) if @job.destroy
    render_js_redirect
  end


  def build
    @error, @content = @job.build
  end


  def history
    @builds = @job.builds.paginate(page: params[:page], per_page: 5)
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
      render_403 unless User.current.allowed_to?(:build_jenkins_jobs, @project)
    end


    def find_job
      @job = @project.jenkins_jobs.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      render_404
    end


    def check_xhr_request
      @is_xhr ||= request.xhr?
    end


    def success_url
      settings_project_path(@project, 'jenkins')
    end


    def render_js_redirect
      respond_to do |format|
        format.js { render js: "window.location = #{success_url.to_json};" }
      end
    end

end
