class JenkinsController < ApplicationController
  unloadable

  # Redmine ApplicationController method
  before_filter :find_project_by_project_id
  before_filter :can_view_jenkins_jobs
  before_filter :find_jenkins_settings

  require 'will_paginate/array'

  helper :redmine_bootstrap_kit
  helper :jenkins


  def index
    @jobs = @project.jenkins_jobs
  end


  def refresh
    success = []
    errors  = []
    @project.jenkins_jobs.each do |job|
      result = BuildManager.update_last_build!(job)
      if result.success?
        success << result.message_on_success
      else
        errors << result.message_on_errors
      end
    end
    flash.now[:notice] = success.uniq.join('<br>').html_safe if !success.empty?
    flash.now[:error]  = errors.uniq.join('<br>').html_safe if !errors.empty?
    @jobs = @project.jenkins_jobs
    render layout: false
  end


  private


    def find_jenkins_settings
      if @project.jenkins_setting.nil?
        flash.now[:warning] = l(:error_no_settings, url: settings_project_path(@project, 'jenkins'))
        render action: 'jenkins_instructions'
      end
    end


    def can_view_jenkins_jobs
      render_403 unless User.current.allowed_to?(:view_jenkins_jobs, @project)
    end

end
