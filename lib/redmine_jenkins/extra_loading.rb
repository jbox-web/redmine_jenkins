module RedmineJenkins
  module ExtraLoading
    # Adds plugin locales if any
    # YAML translation files should be found under <plugin>/config/locales/
    ::I18n.load_path += Dir.glob(File.join(Rails.root, 'plugins', 'redmine_jenkins', 'config', 'locales', '**', '*.yml'))

    # Load Forms and Concerns objects
    services = File.join(Rails.root, 'plugins', 'redmine_jenkins', 'app', 'services')

    if File.directory?(services)
      ActiveSupport::Dependencies.autoload_paths += [services]
    end
  end
end
