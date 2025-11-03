# frozen_string_literal: true

# Clear existing data (development only)
if Rails.env.development?
  puts "🧹 Clearing existing data..."
  UserRole.destroy_all
  NewsPost.destroy_all
  User.destroy_all
  Location.destroy_all
  RssFeed.destroy_all
  Role.destroy_all
end

# Create Roles
puts "👥 Creating roles..."
admin_role = Role.find_or_create_by!(name: 'admin')
general_role = Role.find_or_create_by!(name: 'general')
location_role = Role.find_or_create_by!(name: 'location')

puts "✅ Created #{Role.count} roles"

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
  user.email = nil
end
admin.user_roles.find_or_create_by!(role: admin_role)

# General user (can manage general posts for all locations)
general_user = User.find_or_create_by!(username: 'redaktor') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.email = nil
end
general_user.user_roles.find_or_create_by!(role: general_role)

# Location users (can only manage their location's posts)
locations.each_with_index do |location, index|
  user = User.find_or_create_by!(username: "lokalizacja#{index + 1}") do |u|
    u.password = 'password123'
    u.password_confirmation = 'password123'
    u.location = location
    u.email = nil
  end
  user.user_roles.find_or_create_by!(role: location_role)
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
    post.post_type = :text
    post.location = nil  # nil = general post
    post.user = general_user
    post.published = true
    post.published_at = Time.current
    post.archived = false
  end

  NewsPost.find_or_create_by!(
    title: 'Ważne ogłoszenie dla wszystkich'
  ) do |post|
    post.content = 'To jest kolejne ogłoszenie generalne z formatowaniem tekstu.'
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
    location_user = User.joins(:user_roles, :roles)
                        .where(location: location, roles: { name: 'location' })
                        .first
    
    # Alternate between text and rich_text
    post_type = index.even? ? :text : :rich_text
    
    NewsPost.find_or_create_by!(
      title: "Ogłoszenie dla #{location.code}"
    ) do |post|
      post.content = "To jest ogłoszenie widoczne tylko na ekranie lokalizacji #{location.name}."
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
puts "  - Roles: #{Role.count}"
puts "  - Users: #{User.count}"
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
puts "  - Post types: text, rich_text, image_only"
puts "="*50
