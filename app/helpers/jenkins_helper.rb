module JenkinsHelper

  def user_allowed_to(permission, project)
    return User.current.allowed_to?(permission, project)
  end


  def state_to_css_class(state)
    label_class = ''
    case state.downcase
      when 'success'
        label_class = 'success'
      when 'failure', 'aborted'
        label_class = 'important'
      when 'unstable', 'invalid'
        label_class = 'warning'
      when 'running'
        label_class = 'info'
      when 'not_run'
        label_class = ''
    end
    return label_class
  end


  def state_to_label(state)
    state.gsub('_', ' ').capitalize
  end


  def paginate(collection, params= {})
    will_paginate collection, params.merge(:renderer => WillPaginateHelper::LinkRenderer)
  end


  def plugin_asset_link(asset_name)
    File.join(Redmine::Utils.relative_url_root, 'plugin_assets', 'redmine_jenkins', 'images', asset_name)
  end


  def link_to_jenkins_job(job)
    url    = job.latest_build_number == 0 ? 'javascript:void(0);' : job.latest_build_url
    target = job.latest_build_number == 0 ? '' : 'about_blank'
    link_to "##{job.latest_build_number}", url, :target => target
  end

end
