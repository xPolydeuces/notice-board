# frozen_string_literal: true

class AddPerformanceImprovements < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
        # Add counter caches only if they don't exist
    safety_assured do
      add_column :users, :news_posts_count, :integer, default: 0, null: false unless column_exists?(:users, :news_posts_count)
      add_column :locations, :news_posts_count, :integer, default: 0, null: false unless column_exists?(:locations, :news_posts_count)
    end
 
    # Add composite indexes for better query performance (only if they don't exist)
    unless index_exists?(:news_posts, [:published, :archived, :created_at], name: 'index_news_posts_on_published_archived_created')
      add_index :news_posts, [:published, :archived, :created_at], name: 'index_news_posts_on_published_archived_created', algorithm: :concurrently
    end
 
    unless index_exists?(:news_posts, [:location_id, :published, :archived], name: 'index_news_posts_on_location_published_archived')
      add_index :news_posts, [:location_id, :published, :archived], name: 'index_news_posts_on_location_published_archived', algorithm: :concurrently
    end
 
    unless index_exists?(:news_posts, [:published_at, :archived], name: 'index_news_posts_on_published_at_archived')
      add_index :news_posts, [:published_at, :archived], name: 'index_news_posts_on_published_at_archived', algorithm: :concurrently
    end
 
    # Reset counter caches to accurate values
    reversible do |dir|
      dir.up do
        if column_exists?(:users, :news_posts_count)
          execute <<-SQL.squish
            UPDATE users
            SET news_posts_count = (
              SELECT COUNT(*) FROM news_posts WHERE news_posts.user_id = users.id
            )
          SQL
        end
 
        if column_exists?(:locations, :news_posts_count)
          execute <<-SQL.squish
            UPDATE locations
            SET news_posts_count = (
              SELECT COUNT(*) FROM news_posts WHERE news_posts.location_id = locations.id
            )
          SQL
        end
      end
    end
  end
end