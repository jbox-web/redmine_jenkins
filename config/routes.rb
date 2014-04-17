RedmineApp::Application.routes.draw do
  match 'projects/:id/jenkins/index',        :to => 'jenkins#index'
  match 'projects/:id/jenkins/jobs_list',    :to => 'jenkins#jobs_list', :as => 'refresh_jobs_list'

  match 'projects/:id/jenkins/jobs/:job_id/build',   :to => 'jenkins_jobs#build',   :as => 'job_build',   :job_id => /\d+/
  match 'projects/:id/jenkins/jobs/:job_id/history', :to => 'jenkins_jobs#history', :as => 'job_history', :job_id => /\d+/
  match 'projects/:id/jenkins/jobs/:job_id/console', :to => 'jenkins_jobs#console', :as => 'job_console', :job_id => /\d+/
  match 'projects/:id/jenkins/jobs/:job_id/refresh', :to => 'jenkins_jobs#refresh', :as => 'job_refresh', :job_id => /\d+/

  match 'projects/:id/jenkins_settings/save',      :to => 'jenkins_settings#save',      :as => 'save_jenkins_settings'
  match 'projects/:id/jenkins_settings/jobs_list', :to => 'jenkins_settings#jobs_list', :as => 'get_jobs_list'
end
