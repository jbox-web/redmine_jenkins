module RedmineJenkins
  module Patches
    module QueryPatch

      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          alias_method_chain :available_filters, :redmine_jenkins
          alias_method_chain :sql_for_field,     :redmine_jenkins
        end

      end


      module InstanceMethods

        def available_filters_with_redmine_jenkins
          return @available_filters if @available_filters

          available_filters_without_redmine_jenkins

          return @available_filters unless project

          jenkins_filters

          @jenkins_filters.each do |filter|
            filter.available_values[:name] = I18n.t("field_#{filter.name}")

            if self.respond_to?(:add_available_filter)
              add_available_filter(filter.name, filter.available_values)
            else
              @available_filters[filter.name] = filter.available_values
            end
          end

          return @available_filters
        end


        def sql_for_field_with_redmine_jenkins(field, operator, value, db_table, db_field, is_custom_filter=false)
          case field
            when "jenkins_build"
              return sql_for_jenkins_build(field, operator, value)

            when "jenkins_job"
              return sql_for_jenkins_job(field, operator, value)

            else
              return sql_for_field_without_redmine_jenkins(field, operator, value, db_table, db_field, is_custom_filter)
          end
        end


        private


        def sql_for_jenkins_build(field, operator, value)
          return sql_for_always_false unless project

          jenkins_changesets = find_jenkins_changesets

          return sql_for_issues(jenkins_changesets)
        end


        def sql_for_jenkins_job(field, operator, value)
          return sql_for_always_false unless project

          if filters.has_key?('jenkins_build')
            return sql_for_always_true
          end

          jenkins_changesets = find_jenkins_changesets

          return sql_for_issues(jenkins_changesets)
        end


        # conditions always true
        def sql_for_always_true
          return "#{Issue.table_name}.id > 0"
        end


        # conditions always false
        def sql_for_always_false
          return "#{Issue.table_name}.id < 0"
        end


        def sql_for_issues(jenkins_changesets)
          return sql_for_always_false unless jenkins_changesets
          return sql_for_always_false if jenkins_changesets.length == 0

          value_revisions = jenkins_changesets.collect{|target| "#{ActiveRecord::Base.connection.quote(target.revision.to_s)}"}.join(",")
          sql = "#{Issue.table_name}.id IN"
          sql << "(SELECT changesets_issues.issue_id FROM changesets_issues"
          sql << " WHERE changesets_issues.changeset_id IN"
          sql << "  (SELECT #{Changeset.table_name}.id FROM #{Changeset.table_name}"
          sql << "   WHERE #{Changeset.table_name}.repository_id = #{project.repository.id}"
          sql << "    AND #{Changeset.table_name}.revision IN (#{value_revisions})"
          sql << " )"
          sql << ")"

          return sql
        end


        def find_jenkins_changesets
          retval = []
          find_jenkins_jobs.each do |job|
            builds = find_jenkins_builds(job)
            next if builds.length == 0
            cond_builds = builds.collect{|build| "#{ActiveRecord::Base.connection.quote(build.id.to_s)}"}.join(",")
            retval += JenkinsBuildChangeset.find(:all, :conditions => ["#{JenkinsBuildChangeset.table_name}.jenkins_build_id in (#{cond_builds})"], :order => "#{JenkinsBuildChangeset.table_name}.id DESC", :limit => 100)
          end

          return retval
        end


        def find_jenkins_jobs
          return [] unless project

          if filters.has_key?('jenkins_job')
            cond_jobs = "#{JenkinsJob.table_name}.project_id = #{project.id} and #{conditions_for('jenkins_job', operator_for('jenkins_job'), values_for('jenkins_job'))}"
          else
            cond_jobs = "#{JenkinsJob.table_name}.project_id = #{project.id}"
          end
          return JenkinsJob.find(:all, :conditions => cond_jobs)
        end


        def find_jenkins_builds(job)
          return [] unless job

          if filters.has_key?('jenkins_build')
            cond_builds = conditions_for('jenkins_build', operator_for('jenkins_build'), values_for('jenkins_build'))
          else
            cond_builds = "#{JenkinsBuild.table_name}.id > 0" #always true
          end

          return JenkinsBuild.find(:all, :conditions => ["#{JenkinsBuild.table_name}.jenkins_job_id = ? and #{cond_builds}", job.id], :order => "#{JenkinsBuild.table_name}.number DESC", :limit => 100)
        end


        def jenkins_filters
          @jenkins_filters = []
          return @jenkins_filters unless project
          return @jenkins_filters unless @available_filters

          jenkins_settings = JenkinsSetting.find_by_project_id(project.id)
          return @jenkins_filters unless jenkins_settings

          @jenkins_filters << JenkinsQueryFilter.new(
                                "jenkins_job",
                                {:type   => :list_optional,
                                 :order  => @available_filters.size + 1,
                                 :values => jenkins_settings.jenkins_jobs.collect {|job| [job.name, job.id.to_s]}
                                },
                                JenkinsJob.table_name,
                                "id")

          @jenkins_filters << JenkinsQueryFilter.new(
                                "jenkins_build",
                                { :type => :integer, :order => @available_filters.size + 2 },
                                JenkinsBuild.table_name,
                                "number")

          return @jenkins_filters
        end


        def conditions_for(field, operator, value)
          retval = ""

          available_filters
          return retval unless @jenkins_filters
          filter = @jenkins_filters.detect {|hfilter| hfilter.name == field}
          return retval unless filter

          db_table = filter.db_table
          db_field = filter.db_field

          case operator
          when "="
            retval = "#{db_table}.#{db_field} IN (" + value.collect{|val| "'#{ActiveRecord::Base.connection.quote_string(val)}'"}.join(",") + ")"
          when "!"
            retval = "(#{db_table}.#{db_field} IS NULL OR #{db_table}.#{db_field} NOT IN (" + value.collect{|val| "'#{ActiveRecord::Base.connection.quote_string(val)}'"}.join(",") + "))"
          when "!*"
            retval = "#{db_table}.#{db_field} IS NULL"
            retval << " OR #{db_table}.#{db_field} = ''"
          when "*"
            retval = "#{db_table}.#{db_field} IS NOT NULL"
            retval << " AND #{db_table}.#{db_field} <> ''"
          when ">="
            retval = "#{db_table}.#{db_field} >= #{value.first.to_i}"
          when "<="
            retval = "#{db_table}.#{db_field} <= #{value.first.to_i}"
          when "!~"
            retval = "#{db_table}.#{db_field} NOT LIKE '%#{ActiveRecord::Base.connection.quote_string(value.first.to_s.downcase)}%'"
          end
          return retval
        end

      end

    end
  end
end

unless Query.included_modules.include?(RedmineJenkins::Patches::QueryPatch)
  Query.send(:include, RedmineJenkins::Patches::QueryPatch)
end
