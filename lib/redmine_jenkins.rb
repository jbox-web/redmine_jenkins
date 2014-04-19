# Set up autoload of patches
def apply_patch(&block)
  ActionDispatch::Callbacks.to_prepare(&block)
end

apply_patch do
  require_dependency 'project'
  require_dependency 'projects_controller'
  require_dependency 'projects_helper'
  require_dependency 'query'

  require_dependency 'redmine_jenkins/patches/project_patch'
  require_dependency 'redmine_jenkins/patches/projects_controller_patch'
  require_dependency 'redmine_jenkins/patches/projects_helper_patch'
  require_dependency 'redmine_jenkins/patches/query_patch'

  require_dependency 'redmine_jenkins/hooks/add_activity_icon'
end
