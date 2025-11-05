class AddUsernameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :username, :string
    add_column :users, :location_id, :bigint
    
    # Make email optional
    change_column_null :users, :email, true
    change_column_default :users, :email, from: "", to: nil
  end
end
