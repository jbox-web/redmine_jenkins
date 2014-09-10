module RedmineJenkins
  module ExtraLoading
    # Adds plugin locales if any
    # YAML translation files should be found under <plugin>/config/locales/
    ::I18n.load_path += Dir.glob(File.join(Rails.root, 'plugins', 'redmine_jenkins', 'config', 'locales', '**', '*.yml'))
  end
end
