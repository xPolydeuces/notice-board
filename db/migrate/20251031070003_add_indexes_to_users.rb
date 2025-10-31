class AddIndexesToUsers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!
  
  def change
    add_index :users, :username, unique: true, algorithm: :concurrently
    add_index :users, :location_id, algorithm: :concurrently
    
    add_foreign_key :users, :locations, validate: false
  end
end
