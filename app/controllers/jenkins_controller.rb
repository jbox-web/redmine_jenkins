class JenkinsController < ApplicationController
  unloadable

  # Redmine ApplicationController method
  before_filter :find_project_by_project_id
  before_filter :find_jenkins_settings
  before_filter :can_view_jenkins_jobs

  require 'will_paginate/array'

  helper :jenkins
  helper :will_paginate


  def index
    @jobs = @project.jenkins_jobs
  end


  def refresh
    errors = []

    @project.jenkins_jobs.each do |job|
      manager = BuildManager.new(job)
      if !manager.update_last_build
        errors += manager.errors
      end
    end

    errors = errors.uniq

    if errors.any?
      @errors = "#{l(:error_jenkins_connection)} : #{errors.join(', ')}"
    else
      @errors = ''
    end

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
