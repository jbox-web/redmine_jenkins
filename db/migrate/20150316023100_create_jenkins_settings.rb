class CreateJenkinsSettings < ActiveRecord::Migration

  def change
    create_table :jenkins_settings do |t|
      t.integer :project_id
      t.string  :url
      t.string  :auth_user,         default: ''
      t.string  :auth_password,     default: ''
      t.boolean :show_compact,      default: false
      t.boolean :get_build_details, default: true
      t.boolean :wait_for_build_id, default: false
    end

    add_index :jenkins_settings, :project_id, unique: true
  end

end
