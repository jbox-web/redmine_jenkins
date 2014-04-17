class JenkinsSettingsController < ApplicationController
  unloadable

  before_filter :find_project


  def save
    if !params[:jenkins_setting].nil?
      params[:jenkins_setting][:job_filter] = params[:jenkins_setting][:job_filter].select{|job| !job.blank?}

      if @jenkins_setting.new_record?
        jenkins_setting = JenkinsSetting.new(params[:jenkins_setting])
        jenkins_setting.project_id = @project.id

        if jenkins_setting.save
          flash[:notice] = l(:notice_settings_created)
        else
          flash[:error] = jenkins_setting.errors.full_messages.to_sentence
        end
      else
        if @jenkins_setting.update_attributes(params[:jenkins_setting])
          flash[:notice] = l(:notice_settings_updated)
        else
          flash[:error] = @jenkins_setting.errors.full_messages.to_sentence
        end
      end
    end

    redirect_to :controller => 'projects', :action => 'settings', :tab => 'jenkins', :id => @project
  end


  def jobs_list
    @jobs = @jenkins_setting.get_jobs_list
  end


  private


  def find_project
    @project = Project.find(params[:id])
    if @project.nil?
      render_404
    end

    if @project.jenkins_setting.nil?
      @jenkins_setting = JenkinsSetting.new
    else
      @jenkins_setting = @project.jenkins_setting
    end
  end

end
