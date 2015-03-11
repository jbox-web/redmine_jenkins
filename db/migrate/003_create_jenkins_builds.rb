class CreateJenkinsBuilds < ActiveRecord::Migration

  def up
    create_table :jenkins_builds do |t|
      t.integer  :jenkins_job_id
      t.integer  :number
      t.integer  :author_id
      t.string   :result
      t.datetime :finished_at
      t.boolean  :building
      t.integer  :duration
    end
  end

  def down
    drop_table :jenkins_builds
  end

end
