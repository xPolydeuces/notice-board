# frozen_string_literal: true

class AddPerformanceImprovements < ActiveRecord::Migration[8.1]
  def change
    # Add counter caches
    safety_assured do
      add_column :users, :news_posts_count, :integer, default: 0, null: false
      add_column :locations, :news_posts_count, :integer, default: 0, null: false
    end

    # Add composite indexes for better query performance
    add_index :news_posts, [:published, :archived, :created_at], name: 'index_news_posts_on_published_archived_created'
    add_index :news_posts, [:location_id, :published, :archived], name: 'index_news_posts_on_location_published_archived'
    add_index :news_posts, [:published_at, :archived], name: 'index_news_posts_on_published_at_archived'

    # Reset counter caches to accurate values
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE users
          SET news_posts_count = (
            SELECT COUNT(*) FROM news_posts WHERE news_posts.user_id = users.id
          )
        SQL

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