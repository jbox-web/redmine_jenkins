class CreateJenkinsJobs < ActiveRecord::Migration

  def self.up
    create_table :jenkins_jobs do |t|
      t.column :project_id,            :integer, :null => false
      t.column :repository_id,         :integer, :null => false
      t.column :jenkins_setting_id,    :integer, :null => false
      t.column :name,                  :string,  :null => false
      t.column :latest_build_number,   :integer
      t.column :latest_build_date,     :datetime
      t.column :latest_build_duration, :integer
      t.column :state,                 :string
      t.column :health_report,         :text
      t.column :description,           :text
      t.column :created_at,            :datetime
      t.column :updated_at,            :datetime
    end
  end

  def self.down
    drop_table :jenkins_jobs
  end

end
