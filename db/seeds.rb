# frozen_string_literal: true

# Clear existing data (development only)
if Rails.env.development?
  Rails.logger.debug "🧹 Clearing existing data..."
  NewsPost.destroy_all
  User.destroy_all
  Location.destroy_all
  RssFeed.destroy_all
end

# Create Locations
Rails.logger.debug "📍 Creating locations..."
locations = []

3.times do |i|
  locations << Location.find_or_create_by!(code: "R-#{i + 1}") do |location|
    location.name = "Lokalizacja R-#{i + 1}"
    location.active = true
  end
end

Rails.logger.debug { "✅ Created #{Location.count} locations" }

# Create Users
Rails.logger.debug "👤 Creating users..."

# SUPERADMIN user (first user, can manage everything including other admins)
User.find_or_create_by!(username: "superadmin") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :superadmin
end

# Admin user (can manage most things but not other admins)
admin = User.find_or_create_by!(username: "admin") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :admin
end

# General user (can manage general posts for all locations)
general_user = User.find_or_create_by!(username: "general") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :general
end

# Location users (can only manage their location's posts)
locations.each_with_index do |location, index|
  User.find_or_create_by!(username: "lokalizacja#{index + 1}") do |user|
    user.password = "password123"
    user.password_confirmation = "password123"
    user.role = :location
    user.location = location
  end
end

Rails.logger.debug { "✅ Created #{User.count} users" }

# Create RSS Feeds
Rails.logger.debug "📡 Creating RSS feeds..."

RssFeed.find_or_create_by!(name: "TechCrunch") do |feed|
  feed.url = "https://techcrunch.com/feed/"
  feed.active = true
end

RssFeed.find_or_create_by!(name: "Hacker News") do |feed|
  feed.url = "https://hnrss.org/frontpage"
  feed.active = true
end

RssFeed.find_or_create_by!(name: "BBC News") do |feed|
  feed.url = "http://feeds.bbci.co.uk/news/rss.xml"
  feed.active = false # Example of inactive feed
end

Rails.logger.debug { "✅ Created #{RssFeed.count} RSS feeds" }

# Create sample News Posts
if Rails.env.development?
  Rails.logger.debug "📰 Creating sample news posts..."

  # General posts (location: nil) - visible on ALL location screens
  NewsPost.find_or_create_by!(
    title: "Witamy w systemie tablicy ogłoszeń"
  ) do |post|
    post.content = "To jest ogłoszenie generalne widoczne na wszystkich lokalizacjach."
    post.post_type = :plain_text
    post.location = nil  # nil = general post
    post.user = general_user
    post.published = true
    post.published_at = Time.current
    post.archived = false
  end

  NewsPost.find_or_create_by!(
    title: "Ważne ogłoszenie dla wszystkich"
  ) do |post|
    post.rich_content = "To jest kolejne ogłoszenie generalne z <strong>formatowaniem</strong> tekstu."
    post.post_type = :rich_text
    post.location = nil  # nil = general post
    post.user = admin
    post.published = true
    post.published_at = Time.current
    post.archived = false
  end

  # Draft post (unpublished)
  NewsPost.find_or_create_by!(
    title: "Szkic ogłoszenia"
  ) do |post|
    post.content = "To ogłoszenie jest w trybie roboczym i nie jest jeszcze opublikowane."
    post.post_type = :plain_text
    post.location = nil
    post.user = general_user
    post.published = false
    post.archived = false
  end

  # Archived post
  NewsPost.find_or_create_by!(
    title: "Archiwalne ogłoszenie"
  ) do |post|
    post.content = "To ogłoszenie zostało zarchiwizowane."
    post.post_type = :plain_text
    post.location = nil
    post.user = admin
    post.published = true
    post.published_at = 1.week.ago
    post.archived = true
  end

  # Location-specific posts - visible only on that location's screen
  locations.each_with_index do |location, index|
    # Get the location user
    location_user = User.find_by(location: location, role: :location)

    # Alternate between plain_text and rich_text
    post_type = index.even? ? :plain_text : :rich_text

    NewsPost.find_or_create_by!(
      title: "Ogłoszenie dla #{location.code}"
    ) do |post|
      content_text = "To jest ogłoszenie widoczne tylko na ekranie lokalizacji #{location.name}."
      if post_type == :plain_text
        post.content = content_text
      else
        post.rich_content = content_text
      end
      post.post_type = post_type
      post.location = location # Set location = location-specific
      post.user = location_user
      post.published = true
      post.published_at = Time.current
      post.archived = false
    end
  end

  Rails.logger.debug { "✅ Created #{NewsPost.count} news posts" }
  Rails.logger.debug { "   - #{NewsPost.where(location_id: nil).count} general posts (visible everywhere)" }
  Rails.logger.debug { "   - #{NewsPost.where.not(location_id: nil).count} location-specific posts" }
  Rails.logger.debug { "   - #{NewsPost.where(published: false).count} drafts" }
  Rails.logger.debug { "   - #{NewsPost.where(archived: true).count} archived" }
end

# Summary
Rails.logger.debug { "\n#{'=' * 60}" }
Rails.logger.debug "🎉 Seed completed successfully!"
Rails.logger.debug "=" * 60
Rails.logger.debug "📊 Summary:"
Rails.logger.debug { "  - Users: #{User.count}" }
Rails.logger.debug { "    • Superadmin (ADMIN): #{User.superadmin.count}" }
Rails.logger.debug { "    • Admins: #{User.admin.count}" }
Rails.logger.debug { "    • General: #{User.general.count}" }
Rails.logger.debug { "    • Location: #{User.location.count}" }
Rails.logger.debug { "  - Locations: #{Location.count}" }
Rails.logger.debug { "  - News Posts: #{NewsPost.count}" }
Rails.logger.debug { "  - RSS Feeds: #{RssFeed.count} (#{RssFeed.active.count} active)" }
Rails.logger.debug "\n🔐 Login credentials:"
Rails.logger.debug "  Superadmin: username='superadmin', password='password123'"
Rails.logger.debug "  Admin: username='admin', password='password123'"
Rails.logger.debug "  General: username='general', password='password123'"
locations.each_with_index do |location, index|
  Rails.logger.debug "  Location #{location.code}: username='lokalizacja#{index + 1}', password='password123'"
end
Rails.logger.debug "\n📝 How posts work:"
Rails.logger.debug "  - General posts (location: nil) → shown on ALL location screens"
Rails.logger.debug "  - Location posts (location: R-1) → shown only on that location's screen"
Rails.logger.debug "  - Post types: plain_text, rich_text, image_only"
Rails.logger.debug "  - States: draft (unpublished), published, archived"
Rails.logger.debug "\n👥 User roles:"
Rails.logger.debug "  - Superadmin (ADMIN): Full system access, can manage admins"
Rails.logger.debug "  - Admin: Can manage locations, RSS, all posts, but not other admins"
Rails.logger.debug "  - General: Can create/edit general posts visible on all screens"
Rails.logger.debug "  - Location: Can only create/edit posts for their assigned location"
Rails.logger.debug "\n📡 RSS Feeds:"
Rails.logger.debug "  - Active feeds are fetched automatically every 15 minutes via Sidekiq"
Rails.logger.debug "  - Unhealthy feeds (3+ consecutive errors) are skipped until manually refreshed"
Rails.logger.debug "  - Inactive feeds are stored but not processed"
Rails.logger.debug "=" * 60
