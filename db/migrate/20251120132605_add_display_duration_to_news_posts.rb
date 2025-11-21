# frozen_string_literal: true

class AddDisplayDurationToNewsPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :news_posts, :display_duration, :integer, default: 15, null: false, comment: "Display duration in seconds"
  end
end