# frozen_string_literal: true

require_relative 'license_manager'
require_relative 'license_net'

module Core
  class AILicenseAdapter
    # AI License Guard sistemi için adapter
    # Eksik dosyaları yönetir ve mock implementasyon sağlar
    
    def initialize
      @license_manager = LicenseManager.new
      @model_path = "src/models/license_net.pt"
      @license_path = "src/data/license.key"
      setup_missing_files
    end

    def setup_missing_files
      puts "🔧 Setting up AI License Guard system...".colorize(:cyan)
      
      # Model dosyası kontrolü
      unless File.exist?(@model_path)
        puts "⚠️ Model file not found, creating mock model...".colorize(:yellow)
        create_mock_model
      end

      # License dosyası kontrolü
      unless File.exist?(@license_path)
        puts "⚠️ License file not found, creating demo license...".colorize(:yellow)
        create_demo_license
      end
    end

    def create_mock_model
      # Mock model oluştur
      model_dir = File.dirname(@model_path)
      FileUtils.mkdir_p(model_dir)
      
      mock_model = <<~RUBY
        # Mock License Model - Auto-generated
        # This is a placeholder implementation
        # Replace with actual trained model in production
        
        module Core
          class LockedModel
            def initialize(license_key, license_manager)
              @license_key = license_key
              @license_manager = license_manager
            end

            def predict(fingerprint)
              # Mock prediction
              {
                validity_score: 0.95,
                confidence: 0.98,
                timestamp: Time.now.to_i,
                status: "VALID"
              }
            end
          end
        end
      RUBY
      
      File.write(@model_path, mock_model)
      puts "✅ Mock model created at #{@model_path}".colorize(:green)
    end

    def create_demo_license
      # Demo license oluştur
      license_dir = File.dirname(@license_path)
      FileUtils.mkdir_p(license_dir)
      
      fingerprint = @license_manager.generate_fingerprint
      license_key = @license_manager.generate_license(fingerprint, days: 30)
      
      File.write(@license_path, license_key)
      puts "✅ Demo license created at #{@license_path}".colorize(:green)
    end

    def validate_system
      # Sistemi validate et
      if File.exist?(@license_path)
        license_key = File.read(@license_path).strip
        if @license_manager.validate_license(license_key)
          puts "✅ License validation successful".colorize(:green)
          return true
        else
          puts "❌ License validation failed".colorize(:red)
          return false
        end
      else
        puts "❌ License file missing".colorize(:red)
        return false
      end
    end

    def locked_model
      # LockedModel instance'ı oluştur
      license_key = File.exist?(@license_path) ? File.read(@license_path).strip : ""
      Core::LockedModel.new(license_key, @license_manager)
    rescue => e
      puts "❌ Error creating LockedModel: #{e.message}".colorize(:red)
      nil
    end
  end
end