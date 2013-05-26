class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.integer :user_id, :_null => false
      t.integer :usergroup_id, :_null => false
      t.timestamps
    end
  end
  
  def self.down
    drop_table :roles
  end
end
