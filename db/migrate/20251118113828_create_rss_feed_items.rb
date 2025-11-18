class CreateRssFeedItems < ActiveRecord::Migration[8.1]
  def change
    create_table :rss_feed_items do |t|
      t.references :rss_feed, null: false, foreign_key: true, index: true
      t.string :title, null: false
      t.text :description
      t.string :link
      t.datetime :published_at
      t.string :guid

      t.timestamps
    end

    add_index :rss_feed_items, [:rss_feed_id, :guid], unique: true
    add_index :rss_feed_items, [:rss_feed_id, :published_at]
  end
end