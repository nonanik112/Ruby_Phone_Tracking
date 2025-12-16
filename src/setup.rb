#!/usr/bin/env ruby
# frozen_string_literal: true

# Ruby Phone Tracking System - Setup Script

require 'pathname'
require 'fileutils'
require 'colorize'

puts "🔧 Ruby Phone Tracking System Setup".colorize(:cyan)
puts "=" * 50

# Gerekli dizinleri oluştur
directories = %w[
  data
  data/models
  data/reports
  data/logs
  data/security
  data/recordings
  tmp
  tmp/pids
]

puts "\n📁 Creating directories...".colorize(:yellow)
directories.each do |dir|
  Pathname.new(dir).mkpath
  puts "  ✓ #{dir}".colorize(:green)
end

# Mock model dosyalarını oluştur
puts "\n🤖 Creating mock model files...".colorize(:yellow)

# License model
license_model_path = "data/models/license_net.rb"
unless File.exist?(license_model_path)
  license_model_content = <<~RUBY
    # Mock License Model
    # This is a placeholder for the actual AI model
    # In production, replace with trained model
    
    module Core
      class MockLicenseModel
        def self.validate(fingerprint)
          # Simple validation logic
          return true if fingerprint.length > 10
          false
        end
        
        def self.predict(fingerprint)
          {
            validity_score: 0.95,
            confidence: 0.98,
            timestamp: Time.now.to_i
          }
        end
      end
    end
  RUBY
  
  File.write(license_model_path, license_model_content)
  puts "  ✓ #{license_model_path}".colorize(:green)
end

# Mock ağırlıklar
weights_path = "data/models/weights.pt.enc"
unless File.exist?(weights_path)
  mock_weights = {
    version: "1.0.0",
    timestamp: Time.now.to_i,
    weights: Array.new(100) { rand(-1.0..1.0) },
    bias: rand(-0.5..0.5)
  }
  
  File.write(weights_path, JSON.pretty_generate(mock_weights))
  puts "  ✓ #{weights_path}".colorize(:green)
end

# Demo license oluştur
puts "\n🔑 Creating demo license...".colorize(:yellow)
require_relative '../src/core/license_manager'

license_manager = Core::LicenseManager.new
fingerprint = license_manager.generate_fingerprint
license_key = license_manager.generate_license(fingerprint, days: 30)

license_path = "data/license.key"
File.write(license_path, license_key)
puts "  ✓ #{license_path}".colorize(:green)

# Config dosyası oluştur
puts "\n⚙️ Creating configuration...".colorize(:yellow)
config_path = "config/application.yml"
unless File.exist?(config_path)
  config_content = <<~YAML
    # Ruby Phone Tracking Configuration
    development:
      device_prefix: "RUBY_DEVICE"
      tracking_interval: 30
      database_path: "data/tracking.db"
      log_level: :info
      mock_sensors: true  # For testing without real hardware
    
    production:
      device_prefix: "RUBY_DEVICE"
      tracking_interval: 60
      database_path: "data/tracking.db"
      log_level: :warn
      mock_sensors: false
  YAML
  
  File.write(config_path, config_content)
  puts "  ✓ #{config_path}".colorize(:green)
end

# Gemfile kontrolü
puts "\n📦 Checking dependencies...".colorize(:yellow)
if File.exist?('Gemfile')
  puts "  ✓ Gemfile found".colorize(:green)
  puts "\n💡 Run 'bundle install' to install dependencies".colorize(:cyan)
else
  puts "  ⚠️ Gemfile not found".colorize(:yellow)
end

# Executable izinleri
puts "\n🔒 Setting permissions...".colorize(:yellow)
if File.exist?('bin/tracking')
  File.chmod(0755, 'bin/tracking')
  puts "  ✓ bin/tracking made executable".colorize(:green)
end

puts "\n" + "=" * 50
puts "✅ Setup completed successfully!".colorize(:green)
puts "\n🚀 Next steps:"
puts "  1. bundle install"
puts "  2. ./bin/tracking"
puts "  3. Select option 3 for Demo Mode"
puts "\n📖 For more information, see README.md".colorize(:cyan)