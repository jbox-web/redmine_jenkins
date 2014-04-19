class CreateJenkinsSettings < ActiveRecord::Migration

  def self.up
    create_table :jenkins_settings do |t|
      t.column :project_id,        :int,     :null => false
      t.column :url,               :string,  :null => false
      t.column :auth_user,         :string,  :default => ''
      t.column :auth_password,     :string,  :default => ''
      t.column :show_compact,      :boolean, :default => false
      t.column :get_build_details, :boolean, :default => true
      t.column :wait_for_build_id, :boolean, :default => false
    end
  end

  def self.down
    drop_table :jenkins_settings
  end

end
