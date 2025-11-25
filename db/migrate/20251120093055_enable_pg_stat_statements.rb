class EnablePgStatStatements < ActiveRecord::Migration[8.1]
  def up
    # Enable pg_stat_statements extension for query performance monitoring
    # Required by PgHero to display query statistics
    safety_assured do
      execute "CREATE EXTENSION IF NOT EXISTS pg_stat_statements"
    end
  end

  def down
    safety_assured do
      execute "DROP EXTENSION IF EXISTS pg_stat_statements"
    end
  end
end
