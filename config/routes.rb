RedmineApp::Application.routes.draw do
  match 'projects/:id/jenkins',              :to => 'jenkins#index'
  match 'projects/:id/jenkins/jobs_list',    :to => 'jenkins#jobs_list', :as => 'refresh_jobs_list'

  match 'projects/:id/jenkins/jobs',              :to => 'jenkins_jobs#create',  :via => :post
  match 'projects/:id/jenkins/jobs/new',          :to => 'jenkins_jobs#new',     :via => :get, :as => 'new_jenkins_job'
  match 'projects/:id/jenkins/jobs/:job_id/edit', :to => 'jenkins_jobs#edit',    :via => :get, :as => 'edit_jenkins_job'
  match 'projects/:id/jenkins/jobs/:job_id',      :to => 'jenkins_jobs#show',    :via => :get, :as => 'jenkins_job'
  match 'projects/:id/jenkins/jobs/:job_id',      :to => 'jenkins_jobs#update',  :via => :put
  match 'projects/:id/jenkins/jobs/:job_id',      :to => 'jenkins_jobs#destroy', :via => :delete

  match 'projects/:id/jenkins/jobs/:job_id/build',   :to => 'jenkins_jobs#build',   :as => 'job_build',   :job_id => /\d+/
  match 'projects/:id/jenkins/jobs/:job_id/history', :to => 'jenkins_jobs#history', :as => 'job_history', :job_id => /\d+/
  match 'projects/:id/jenkins/jobs/:job_id/console', :to => 'jenkins_jobs#console', :as => 'job_console', :job_id => /\d+/
  match 'projects/:id/jenkins/jobs/:job_id/refresh', :to => 'jenkins_jobs#refresh', :as => 'job_refresh', :job_id => /\d+/

  match 'projects/:id/jenkins_settings/save',            :to => 'jenkins_settings#save',            :as => 'save_jenkins_settings'
  match 'projects/:id/jenkins_settings/test_connection', :to => 'jenkins_settings#test_connection', :as => 'test_jenkins_settings'
end
