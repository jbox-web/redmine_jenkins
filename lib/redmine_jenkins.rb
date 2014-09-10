ActionDispatch::Callbacks.to_prepare do
  require_dependency 'redmine_jenkins/patches/project_patch'
  require_dependency 'redmine_jenkins/patches/projects_controller_patch'
  require_dependency 'redmine_jenkins/patches/projects_helper_patch'
  require_dependency 'redmine_jenkins/patches/query_patch'

  require_dependency 'redmine_jenkins/hooks/add_activity_icon'

  require_dependency 'redmine_jenkins/extra_loading'
end
