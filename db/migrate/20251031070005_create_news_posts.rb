class CreateNewsPosts < ActiveRecord::Migration[8.0]
  def change
    create_table :news_posts do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.string :post_type, null: false # 'general' or 'location'
      t.references :location, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :published, default: false, null: false
      t.datetime :published_at
      t.boolean :archived, default: false, null: false
      
      t.timestamps
    end
    
    add_index :news_posts, :post_type
    add_index :news_posts, :published
    add_index :news_posts, :archived
    add_index :news_posts, [:location_id, :published]
  end
end
