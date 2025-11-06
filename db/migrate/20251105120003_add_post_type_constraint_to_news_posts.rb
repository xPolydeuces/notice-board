# frozen_string_literal: true

class AddPostTypeConstraintToNewsPosts < ActiveRecord::Migration[8.1]
  def up
    add_check_constraint :news_posts, "post_type IN ('general', 'location')", name: 'check_news_posts_post_type', validate: false
  end

  def down
    remove_check_constraint :news_posts, name: 'check_news_posts_post_type'
  end
end
