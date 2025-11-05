class AddRoleEnumToUsers < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    # Add role column as integer (for enum)
    add_column :users, :role, :integer, default: 0, null: false
    
    # Add index for performance
    add_index :users, :role, algorithm: :concurrently
  end
  
  def down
    remove_index :users, :role, algorithm: :concurrently
    remove_column :users, :role
  end
end
