# coding: utf-8

require 'redmine'

require 'redmine_jenkins'

Redmine::Plugin.register :redmine_jenkins do
  name 'Redmine Jenkins plugin'
  author 'Toshiyuki Ando r-labs, Nicolas Rodriguez'
  description 'This is a Jenkins plugin for Redmine'
  version '0.1'
  url 'https://github.com/jbox-web/redmine_jenkins'
  author_url 'https://github.com/jbox-web'

  project_module :jenkins do
    permission :view_jenkins_jobs,     {:jenkins  => [:index]}
    permission :build_jenkins_jobs,    {:jenkins  => [:start_build]}
    permission :view_build_activity,   {:activity => [:index]}
    permission :edit_jenkins_settings, {:jenkins_settings => [:save_settings]}
  end

  Redmine::MenuManager.map :project_menu do |menu|
    menu.push :jenkins, { :controller => 'jenkins', :action => 'index' }, :caption => :label_jenkins, :after => :repository
  end

  activity_provider :build_activity, :default => true, :class_name => ['JenkinsBuild']

end
