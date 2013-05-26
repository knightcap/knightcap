class CreateGlobalblists < ActiveRecord::Migration
  def change
    create_table :globalblists do |t|
      t.string :email

      t.timestamps
    end
  end
end
