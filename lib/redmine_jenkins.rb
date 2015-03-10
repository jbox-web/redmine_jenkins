## Redmine Views Hooks
require 'redmine_jenkins/hooks/add_activity_icon'

## Set up autoload of patches
Rails.configuration.to_prepare do

  ## Redmine Jenkins Libs and Patches
  rbfiles = Rails.root.join('plugins', 'redmine_jenkins', 'lib', 'redmine_jenkins', '**', '*.rb')
  Dir.glob(rbfiles).each do |file|
    # Exclude Redmine Views Hooks from Rails loader to avoid multiple calls to hooks on reload in dev environment.
    require_dependency file unless File.dirname(file) == Rails.root.join('plugins', 'redmine_jenkins', 'lib', 'redmine_jenkins', 'hooks').to_s
  end

end
