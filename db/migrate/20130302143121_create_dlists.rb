class CreateDlists < ActiveRecord::Migration
  def change
    create_table :dlists do |t|
      t.string :email
      t.references :service
      
      t.timestamps
    end
  end
end
