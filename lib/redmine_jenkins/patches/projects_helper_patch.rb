module RedmineJenkins
  module Patches
    module ProjectsHelperPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          alias_method_chain :project_settings_tabs, :redmine_jenkins
        end
      end


      module InstanceMethods

        def project_settings_tabs_with_redmine_jenkins(&block)
          tabs = project_settings_tabs_without_redmine_jenkins(&block)
          tabs.push({
            :name    => 'jenkins',
            :action  => :edit_jenkins_settings,
            :partial => 'projects/settings/redmine_jenkins',
            :label   => :label_jenkins
          })
          tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
        end

      end

    end
  end
end

unless ProjectsHelper.included_modules.include?(RedmineJenkins::Patches::ProjectsHelperPatch)
  ProjectsHelper.send(:include, RedmineJenkins::Patches::ProjectsHelperPatch)
end
