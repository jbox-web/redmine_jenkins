class RemoveSettingsFieldFromJenkinsJobs < ActiveRecord::Migration

  def up
    remove_column :jenkins_jobs, :jenkins_setting_id
  end

  def down
    add_column :jenkins_jobs, :jenkins_setting_id, :integer, after: :project_id
  end

end
