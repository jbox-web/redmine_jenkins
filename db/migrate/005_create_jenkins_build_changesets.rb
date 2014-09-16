class CreateJenkinsBuildChangesets < ActiveRecord::Migration

  def self.up
    create_table :jenkins_build_changesets do |t|
      t.column :jenkins_build_id, :integer
      t.column :repository_id,    :integer
      t.column :revision,         :string
      t.column :comment,          :text, limit: 4294967295
    end
  end

  def self.down
    drop_table :jenkins_build_changesets
  end

end
