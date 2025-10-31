class CreateRssFeeds < ActiveRecord::Migration[8.0]
  def change
    create_table :rss_feeds do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.boolean :active, default: true, null: false
      t.datetime :last_fetched_at
      
      t.timestamps
    end
    
    add_index :rss_feeds, :active
  end
end
