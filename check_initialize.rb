# check_initialize.rb
require_relative "config/application"

puts "Rails.application: #{Rails.application.inspect}"
puts "Methods: #{Rails.application.methods(false).grep(/initialize/)}"
