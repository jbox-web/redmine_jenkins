class CreateJenkinsSettings < ActiveRecord::Migration

  def up
    create_table :jenkins_settings do |t|
      t.integer :project_id
      t.string  :url
      t.string  :auth_user,         default: ''
      t.string  :auth_password,     default: ''
      t.boolean :show_compact,      default: false
      t.boolean :get_build_details, default: true
      t.boolean :wait_for_build_id, default: false
    end
  end

  def down
    drop_table :jenkins_settings
  end

end
