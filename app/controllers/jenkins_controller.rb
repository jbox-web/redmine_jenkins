class JenkinsController < ApplicationController
  unloadable

  before_filter :find_project
  before_filter :can_view_jenkins_jobs
  before_filter :find_jobs, :only => [:index]

  layout Proc.new { |controller| controller.request.xhr? ? 'popup' : 'base' }

  require 'will_paginate/array'

  helper :jenkins
  helper :will_paginate


  def index
  end


  def refresh
    errors = []

    @jenkins_setting.jobs.each do |job|
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
    find_jobs
  end


  private


  def find_project
    @project = Project.find(params[:project_id])
    if @project.nil?
      render_404
    end

    if @project.jenkins_setting.nil?
      render :action => 'jenkins_instructions'
    else
      @jenkins_setting = @project.jenkins_setting
    end
  end


  def can_view_jenkins_jobs
    render_403 unless view_context.user_allowed_to(:view_jenkins_jobs, @project)
  end


  def find_jobs
    @jobs = JenkinsJob.find_all_by_project_id(@project.id)
  end

end
