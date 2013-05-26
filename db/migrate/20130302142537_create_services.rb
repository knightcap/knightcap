class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.text :email_content, :limit => nil
      t.references :team
      t.timestamps
    end
  end
end
