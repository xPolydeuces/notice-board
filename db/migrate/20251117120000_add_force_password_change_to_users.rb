# frozen_string_literal: true

class AddForcePasswordChangeToUsers < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :users, :force_password_change, :boolean, default: false, null: false
    add_index :users, :force_password_change, algorithm: :concurrently
  end
end