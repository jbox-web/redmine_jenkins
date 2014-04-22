class JenkinsSettingsController < ApplicationController
  unloadable

  before_filter :find_project

  layout Proc.new { |controller| controller.request.xhr? ? 'popup' : 'base' }


  def save
    if !params[:jenkins_setting].nil?
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


  def test_connection
    @error, @content = @jenkins_setting.get_jenkins_version
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
