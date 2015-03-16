class CreateChangesetsJenkinsBuilds < ActiveRecord::Migration

  def change
    create_table :changesets_jenkins_builds do |t|
      t.integer :changeset_id
      t.integer :jenkins_build_id
    end

    add_index :changesets_jenkins_builds, :changeset_id
    add_index :changesets_jenkins_builds, :jenkins_build_id
    add_index :changesets_jenkins_builds, [:changeset_id, :jenkins_build_id], unique: true, name: 'unique_index_on_changeset_jenkins_build'
  end

end
