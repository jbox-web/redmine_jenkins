class AddMissingIndexes < ActiveRecord::Migration

  def up
    add_index :jenkins_settings, :project_id

    add_index :jenkins_jobs, :project_id
    add_index :jenkins_jobs, :repository_id
    add_index :jenkins_jobs, [:project_id, :name], unique: true

    add_index :jenkins_builds, :jenkins_job_id
    add_index :jenkins_builds, :author_id

    add_index :jenkins_build_changesets, :jenkins_build_id
    add_index :jenkins_build_changesets, :repository_id

    add_index :jenkins_test_results, :jenkins_build_id
  end


  def down

  end

end
