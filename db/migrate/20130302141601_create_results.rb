class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.string :email
      t.boolean :done
      t.integer :score
      t.string :comments
      t.references :survey

      t.timestamps
    end
  end
end
