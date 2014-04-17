module RedmineJenkins
  module Patches
    module ProjectPatch

      def self.included(base)
        base.class_eval do
          unloadable

          has_one :jenkins_setting, :foreign_key => 'project_id', :class_name => 'JenkinsSetting', :dependent => :destroy
        end
      end

    end
  end
end

unless Project.included_modules.include?(RedmineJenkins::Patches::ProjectPatch)
  Project.send(:include, RedmineJenkins::Patches::ProjectPatch)
end
