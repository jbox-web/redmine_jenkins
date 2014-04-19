class CreateJenkinsBuildChangesets < ActiveRecord::Migration

  def self.up
    create_table :jenkins_build_changesets do |t|
      t.column :jenkins_build_id, :integer, :null => false
      t.column :repository_id,    :integer, :null => false
      t.column :revision,         :string,  :null => false
      t.column :comment,          :text,    :null => false, :limit => 4294967295
    end
  end

  def self.down
    drop_table :jenkins_build_changesets
  end

end
