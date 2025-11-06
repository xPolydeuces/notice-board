# frozen_string_literal: true

class AddUniqueIndexToRssFeedsUrl < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!
  
  def change
    add_index :rss_feeds, :url, unique: true, algorithm: :concurrently
  end
end
