# frozen_string_literal: true

class RemoveRoleTables < ActiveRecord::Migration[8.1]
  def up
    # Remove the join table approach in favor of enum-based roles
    drop_table :user_roles if table_exists?(:user_roles)
    drop_table :roles if table_exists?(:roles)
  end

  def down
    # Recreate roles table
    create_table :roles do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :roles, :name, unique: true

    # Recreate user_roles table
    create_table :user_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.timestamps
    end
    add_index :user_roles, %i[user_id role_id], unique: true
  end
end
