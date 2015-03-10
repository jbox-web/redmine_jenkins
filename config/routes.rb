scope 'projects/:project_id' do
  get 'jenkins',         to: 'jenkins#index'
  get 'jenkins/refresh', to: 'jenkins#refresh'

  put 'jenkins_settings/save'
  get 'jenkins_settings/test_connection'

  resources :jenkins_jobs do
    member do
      get 'build'
      get 'history'
      get 'console'
      get 'refresh'
    end
  end
end
