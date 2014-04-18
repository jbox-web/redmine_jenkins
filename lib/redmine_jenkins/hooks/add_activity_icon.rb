module RedmineJenkins
  module Hooks
    class AddActivityIcon < Redmine::Hook::ViewListener

      def view_layouts_base_html_head(context={})
        project = context[:project]
        return '' unless project
        controller = context[:controller]
        return '' unless controller
        action_name = controller.action_name
        return '' unless action_name

        if (controller.class.name == 'ActivitiesController' and action_name == 'index')
          return stylesheet_link_tag(:application, :plugin => 'redmine_jenkins')
        end
      end

    end
  end
end
