class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.boolean :active, default: true, null: false
      
      t.timestamps
    end
    
    add_index :locations, :code, unique: true
    add_index :locations, :active
  end
end
