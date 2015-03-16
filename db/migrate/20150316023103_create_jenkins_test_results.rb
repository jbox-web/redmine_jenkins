class CreateJenkinsTestResults < ActiveRecord::Migration

  def change
    create_table :jenkins_test_results do |t|
      t.integer :jenkins_build_id
      t.integer :fail_count
      t.integer :skip_count
      t.integer :total_count
    end

    add_index :jenkins_test_results, :jenkins_build_id
  end

end
