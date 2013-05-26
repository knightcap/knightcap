class CreateServiceusers < ActiveRecord::Migration
  def change
    create_table :servicesusers do |t|
      t.integer :user_id, :_null => false
      t.integer :service_id, :_null => false
      t.string :ews_id
      t.string :ews_name
      t.timestamps
    end
  end
  
  def self.down
    drop_table :servicesusers
  end
end
