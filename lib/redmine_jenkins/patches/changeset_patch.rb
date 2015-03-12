require_dependency 'changeset'

module RedmineJenkins
  module Patches
    module ChangesetPatch

      def self.included(base)
        base.class_eval do
          unloadable

          has_and_belongs_to_many :jenkins_builds
        end
      end

    end
  end
end

unless Changeset.included_modules.include?(RedmineJenkins::Patches::ChangesetPatch)
  Changeset.send(:include, RedmineJenkins::Patches::ChangesetPatch)
end
