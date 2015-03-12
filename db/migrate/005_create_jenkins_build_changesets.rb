class CreateJenkinsBuildChangesets < ActiveRecord::Migration

  def up
    create_table :jenkins_build_changesets do |t|
      t.integer :jenkins_build_id
      t.integer :repository_id
      t.string  :revision
      t.text    :comment, limit: 16.megabytes - 1
    end
  end

  def down
    drop_table :jenkins_build_changesets
  end

end
