class CreateChangesetsJenkinsBuilds < ActiveRecord::Migration

  def up
    create_table :changesets_jenkins_builds, id: false do |t|
      t.integer :changeset_id
      t.integer :jenkins_build_id
    end

    drop_table :jenkins_build_changesets
  end

  def down
    drop_table :changesets_jenkins_builds

    create_table :jenkins_build_changesets do |t|
      t.integer :jenkins_build_id
      t.integer :repository_id
      t.string  :revision
      t.text    :comment, limit: 16.megabytes - 1
    end
  end

end
