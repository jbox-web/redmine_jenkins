class CreateJenkinsTestResults < ActiveRecord::Migration

  def self.up
    create_table :jenkins_test_results do |t|
      t.column :jenkins_build_id, :integer, :null => false
      t.column :fail_count,       :integer
      t.column :skip_count,       :integer
      t.column :total_count,      :integer
    end
  end

  def self.down
    drop_table :jenkins_test_results
  end

end
