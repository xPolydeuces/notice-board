class MakeNewsPostContentNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :news_posts, :content, true
  end
end