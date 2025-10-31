class ValidateAddIndexesToUsers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!
  
  def change
    validate_foreign_key :users, :locations
  end
end
