# frozen_string_literal: true

class ValidatePostTypeConstraintOnNewsPosts < ActiveRecord::Migration[8.1]
  def up
    validate_check_constraint :news_posts, name: 'check_news_posts_post_type'
  end

  def down
    # No-op: Constraint remains in place but unvalidated
  end
end