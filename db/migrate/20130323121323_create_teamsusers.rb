class CreateTeamsusers < ActiveRecord::Migration
  def change
    create_table :teamsusers do |t|
      t.integer :team_id, :_null => false
      t.integer :user_id, :_null => false
      
      t.string :role, :default => "member"
      t.timestamps
    end
  end
  
  def self.down
    drop_table :teamsusers
  end
end
