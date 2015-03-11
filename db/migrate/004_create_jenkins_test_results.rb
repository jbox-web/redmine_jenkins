class CreateJenkinsTestResults < ActiveRecord::Migration

  def up
    create_table :jenkins_test_results do |t|
      t.integer :jenkins_build_id
      t.integer :fail_count
      t.integer :skip_count
      t.integer :total_count
    end
  end

  def down
    drop_table :jenkins_test_results
  end

end
