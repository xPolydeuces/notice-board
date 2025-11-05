# frozen_string_literal: true

class AddUniqueIndexToRssFeedsUrl < ActiveRecord::Migration[8.1]
  def change
    add_index :rss_feeds, :url, unique: true
  end
end
