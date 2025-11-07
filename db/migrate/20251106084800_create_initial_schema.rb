class CreateInitialSchema < ActiveRecord::Migration[8.1]
  def change
    # Locations table
    create_table :locations do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.boolean :active, null: false, default: true
      t.integer :news_posts_count, null: false, default: 0
      t.integer :users_count, null: false, default: 0

      t.timestamps
    end

    add_index :locations, :code, unique: true
    add_index :locations, :active

    # Users table with Devise
    # Note: Using username-based authentication instead of email-based
    create_table :users do |t|
      # Devise: database authenticatable
      t.string :encrypted_password, null: false, default: ""
      # Devise: rememberable, trackable, timeoutable
      t.datetime :remember_created_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      # Custom fields
      t.string :username, null: false
      t.references :location, foreign_key: true
      t.integer :role, null: false, default: 0
      t.integer :news_posts_count, null: false, default: 0

      t.timestamps
    end

    add_index :users, :username, unique: true
    add_index :users, :role

    # News posts table
    create_table :news_posts do |t|
      t.string :title, null: false
      t.text :content  # Nullable: rich_text uses ActionText, image_only uses ActiveStorage
      t.string :post_type, null: false
      t.references :location, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :published, null: false, default: false
      t.datetime :published_at
      t.boolean :archived, null: false, default: false

      t.timestamps
    end

    # Add indexes for news_posts
    add_index :news_posts, :post_type
    add_index :news_posts, :published
    add_index :news_posts, :archived
    add_index :news_posts, [:location_id, :published]
    add_index :news_posts, [:location_id, :published, :archived], name: 'index_news_posts_on_location_published_archived'
    add_index :news_posts, [:published, :archived, :created_at], name: 'index_news_posts_on_published_archived_created'
    add_index :news_posts, [:published_at, :archived], name: 'index_news_posts_on_published_at_archived'

    # RSS feeds table
    create_table :rss_feeds do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.boolean :active, null: false, default: true
      t.datetime :last_fetched_at

      t.timestamps
    end

    add_index :rss_feeds, :url, unique: true
    add_index :rss_feeds, :active
  end
end