class CreateJenkinsBuilds < ActiveRecord::Migration

  def change
    create_table :jenkins_builds do |t|
      t.integer  :jenkins_job_id
      t.integer  :number
      t.integer  :author_id
      t.string   :result
      t.datetime :finished_at
      t.boolean  :building
      t.integer  :duration
    end

    add_index :jenkins_builds, :jenkins_job_id
    add_index :jenkins_builds, :author_id
  end

end
