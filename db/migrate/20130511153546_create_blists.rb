class CreateBlists < ActiveRecord::Migration
  def change
    create_table :blists do |t|
      t.string :email
      t.references :service

      t.timestamps
    end
  end
end
