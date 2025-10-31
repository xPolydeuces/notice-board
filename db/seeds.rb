# frozen_string_literal: true

return if Rails.env.test?

puts "🌱 Seeding database..."

# Create Roles
puts "Creating roles..."
admin_role = Role.find_or_create_by!(name: "Admin", id: Role::ADMIN_ID)
general_role = Role.find_or_create_by!(name: "General", id: Role::GENERAL_ID)
location_role = Role.find_or_create_by!(name: "Location", id: Role::LOCATION_ID)
puts "✅ Roles created"

# Create sample locations (development only)
if Rails.env.development?
  puts "Creating sample locations..."
  Location.find_or_create_by!(code: "R-1") do |loc|
    loc.name = "Woronicza"
  end
  
  Location.find_or_create_by!(code: "R-2") do |loc|
    loc.name = "Kleszczowa"
  end
  
  Location.find_or_create_by!(code: "R-3") do |loc|
    loc.name = "Ostrobramska"
  end
  puts "✅ Sample locations created"

  # Create admin user (development only)
  puts "Creating admin user..."
  admin = User.find_or_create_by!(username: "admin") do |user|
    user.password = "password123"
    user.password_confirmation = "password123"
  end
  admin.roles << admin_role unless admin.roles.include?(admin_role)
  puts "✅ Admin user created (username: admin, password: password123)"

  # Create general user (development only)
  puts "Creating general user..."
  general = User.find_or_create_by!(username: "general") do |user|
    user.password = "password123"
    user.password_confirmation = "password123"
  end
  general.roles << general_role unless general.roles.include?(general_role)
  puts "✅ General user created (username: general, password: password123)"

  # Create location user (development only)
  puts "Creating location user..."
  location_user = User.find_or_create_by!(username: "woronicza") do |user|
    user.password = "password123"
    user.password_confirmation = "password123"
    user.location = Location.find_by(code: "R-1")
  end
  location_user.roles << location_role unless location_user.roles.include?(location_role)
  puts "✅ Location user created (username: woronicza, password: password123)"
end

puts "✨ Seeding complete!"
