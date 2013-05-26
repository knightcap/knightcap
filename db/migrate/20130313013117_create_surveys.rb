class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.references :service
      t.timestamps
    end
  end
  
  def self.down
    drop_table :surveys
  end
end
