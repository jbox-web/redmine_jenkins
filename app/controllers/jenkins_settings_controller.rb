class JenkinsSettingsController < ApplicationController
  unloadable

  # Redmine ApplicationController method
  before_filter :find_project_by_project_id
  before_filter :load_jenkins_settings


  def save
    unless params[:jenkins_setting].nil?
      if @jenkins_setting.update_attributes(params[:jenkins_setting])
        flash[:notice] = l(:notice_settings_updated)
      else
        flash[:error] = @jenkins_setting.errors.full_messages.to_sentence
      end
    end
    redirect_to settings_project_path(@project, 'jenkins')
  end


  def test_connection
    @content = @jenkins_setting.test_connection
    render layout: false
  end


  private


    def load_jenkins_settings
      if @project.jenkins_setting.nil?
        @jenkins_setting = @project.build_jenkins_setting
      else
        @jenkins_setting = @project.jenkins_setting
      end
    end

end
