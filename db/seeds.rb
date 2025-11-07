# frozen_string_literal: true

# Clear existing data (development only)
if Rails.env.development?
  puts "🧹 Clearing existing data..."
  NewsPost.destroy_all
  User.destroy_all
  Location.destroy_all
  RssFeed.destroy_all
end

# Create Locations
puts "📍 Creating locations..."
locations = []

3.times do |i|
  locations << Location.find_or_create_by!(code: "R-#{i + 1}") do |location|
    location.name = "Lokalizacja R-#{i + 1}"
    location.active = true
  end
end

puts "✅ Created #{Location.count} locations"

# Create Users
puts "👤 Creating users..."

# Admin user
admin = User.find_or_create_by!(username: 'admin') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = :admin
end

# General user (can manage general posts for all locations)
general_user = User.find_or_create_by!(username: 'redaktor') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = :general
end

# Location users (can only manage their location's posts)
locations.each_with_index do |location, index|
  User.find_or_create_by!(username: "lokalizacja#{index + 1}") do |user|
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.role = :location
    user.location = location
  end
end

puts "✅ Created #{User.count} users"

# Create sample News Posts
if Rails.env.development?
  puts "📰 Creating sample news posts..."

  # General posts (location: nil) - visible on ALL location screens
  NewsPost.find_or_create_by!(
    title: 'Witamy w systemie tablicy ogłoszeń'
  ) do |post|
    post.content = 'To jest ogłoszenie generalne widoczne na wszystkich lokalizacjach.'
    post.post_type = :plain_text
    post.location = nil  # nil = general post
    post.user = general_user
    post.published = true
    post.published_at = Time.current
    post.archived = false
  end

  NewsPost.find_or_create_by!(
    title: 'Ważne ogłoszenie dla wszystkich'
  ) do |post|
    post.rich_content = 'To jest kolejne ogłoszenie generalne z formatowaniem tekstu.'
    post.post_type = :rich_text
    post.location = nil  # nil = general post
    post.user = admin
    post.published = true
    post.published_at = Time.current
    post.archived = false
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
      post.location = location  # Set location = location-specific
      post.user = location_user
      post.published = true
      post.published_at = Time.current
      post.archived = false
    end
  end

  puts "✅ Created #{NewsPost.count} news posts"
  puts "   - #{NewsPost.general.count} general posts (visible everywhere)"
  puts "   - #{NewsPost.where.not(location_id: nil).count} location-specific posts"
end

# Summary
puts "\n" + "="*50
puts "🎉 Seed completed successfully!"
puts "="*50
puts "📊 Summary:"
puts "  - Users: #{User.count}"
puts "    • Admins: #{User.admin.count}"
puts "    • General: #{User.general.count}"
puts "    • Location: #{User.location.count}"
puts "  - Locations: #{Location.count}"
puts "  - News Posts: #{NewsPost.count}"
puts "  - RSS Feeds: #{RssFeed.count}"
puts "\n🔐 Login credentials:"
puts "  Admin: username='admin', password='password123'"
puts "  General: username='redaktor', password='password123'"
locations.each_with_index do |location, index|
  puts "  Location #{location.code}: username='lokalizacja#{index + 1}', password='password123'"
end
puts "\n📝 How posts work:"
puts "  - General posts (location: nil) → shown on ALL location screens"
puts "  - Location posts (location: R-1) → shown only on that location's screen"
puts "  - Post types: plain_text, rich_text, image_only"
puts "\n👥 User roles:"
puts "  - Admin: Can manage everything (users, locations, RSS, all posts)"
puts "  - General: Can create/edit general posts visible on all screens"
puts "  - Location: Can only create/edit posts for their assigned location"
puts "="*50