require_dependency 'project'

module RedmineJenkins
  module Patches
    module ProjectPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          has_one  :jenkins_setting, dependent: :destroy
          has_many :jenkins_jobs,    dependent: :destroy
        end
      end


      module InstanceMethods

        def jenkins_url
          jenkins_setting.url
        end


        def jenkins_connection
          jenkins_setting.jenkins_connection
        end


        def wait_for_build_id
          jenkins_setting.wait_for_build_id
        end

      end

    end
  end
end

unless Project.included_modules.include?(RedmineJenkins::Patches::ProjectPatch)
  Project.send(:include, RedmineJenkins::Patches::ProjectPatch)
end
