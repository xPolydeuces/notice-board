class RemoveDuplicateIndexes < ActiveRecord::Migration[8.1]
  
  def change
    # Remove duplicate index on news_posts.location_id
    # Covered by index_news_posts_on_location_id_and_published
    remove_index :news_posts, name: :index_news_posts_on_location_id, if_exists: true

    # Remove duplicate index on news_posts (location_id, published)
    # Covered by index_news_posts_on_location_published_archived
    remove_index :news_posts, name: :index_news_posts_on_location_id_and_published, if_exists: true

    # Remove duplicate index on news_posts.published
    # Covered by index_news_posts_on_published_archived_created
    remove_index :news_posts, name: :index_news_posts_on_published, if_exists: true

    # Remove duplicate index on rss_feed_items.rss_feed_id
    # Covered by index_rss_feed_items_on_rss_feed_id_and_guid
    remove_index :rss_feed_items, name: :index_rss_feed_items_on_rss_feed_id, if_exists: true
  end
end