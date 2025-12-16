# frozen_string_literal: true

require 'digest'
require 'json'
require 'time'

module Core
  class LicenseManager
    # AI License Guard sisteminin Ruby implementasyonu
    
    def initialize(model_path = "src/models/license_net.rb")
      @model_path = Pathname.new(model_path)
      @license_file = Pathname.new("src/data/license.key")
      @fingerprint_file = Pathname.new("src/data/fingerprint.json")
    end

    def generate_fingerprint
      # Sistem finger-print'i oluştur
      fingerprint = {
        cpu: get_cpu_info,
        mac: get_mac_address,
        hostname: Socket.gethostname,
        ruby_version: RUBY_VERSION,
        platform: RUBY_PLATFORM,
        timestamp: Time.now.to_i
      }
      
      @fingerprint_file.dirname.mkpath
      @fingerprint_file.write(JSON.pretty_generate(fingerprint))
      
      Digest::SHA256.hexdigest(fingerprint.values.join('|'))
    end

    def get_cpu_info
      begin
        if RUBY_PLATFORM =~ /linux/
          `grep -m1 "model name" /proc/cpuinfo`.split(':')[1]&.strip || "Unknown"
        elsif RUBY_PLATFORM =~ /darwin/
          `sysctl -n machdep.cpu.brand_string`.strip
        else
          "Windows CPU"
        end
      rescue
        "Unknown"
      end
    end

    def get_mac_address
      begin
        # İlk network interface'in MAC adresini al
        interfaces = Socket.getifaddrs
        interface = interfaces.find { |i| i.addr&.ipv4? && !i.addr.ip_address.start_with?('127.') }
        interface&.addr&.getnameinfo&.first || "00:00:00:00:00:00"
      rescue
        "00:00:00:00:00:00"
      end
    end

    def generate_license(fingerprint, days: 365)
      # License key oluştur
      expiry = Time.now + (days * 24 * 60 * 60)
      
      license_data = {
        fingerprint: fingerprint,
        issued: Time.now.to_i,
        expiry: expiry.to_i,
        version: "1.0.0",
        type: "evaluation"
      }
      
      # JSON'u şifrele ve base64 encode et
      encrypted = encrypt_license_data(license_data)
      Base64.strict_encode64(encrypted)
    end

    def validate_license(license_key)
      begin
        # License key'i decode et ve çöz
        encrypted_data = Base64.strict_decode64(license_key)
        license_data = decrypt_license_data(encrypted_data)
        
        # Süre kontrolü
        return false if Time.now.to_i > license_data[:expiry]
        
        # Fingerprint kontrolü
        current_fingerprint = generate_fingerprint
        return false unless license_data[:fingerprint] == current_fingerprint
        
        true
      rescue => e
        puts "License validation error: #{e.message}".colorize(:red)
        false
      end
    end

    def encrypt_license_data(data)
      # Basit XOR şifreleme (gerçek uygulamada daha güçlü şifreleme kullan)
      key = Digest::SHA256.hexdigest("ruby_license_key_2024")
      data_str = JSON.generate(data)
      
      encrypted = data_str.chars.each_with_index.map do |char, idx|
        key_char = key[idx % key.length].ord
        (char.ord ^ key_char).chr
      end.join
      
      encrypted
    end

    def decrypt_license_data(encrypted_data)
      # XOR çözme
      key = Digest::SHA256.hexdigest("ruby_license_key_2024")
      
      decrypted = encrypted_data.chars.each_with_index.map do |char, idx|
        key_char = key[idx % key.length].ord
        (char.ord ^ key_char).chr
      end.join
      
      JSON.parse(decrypted, symbolize_names: true)
    end

    def create_demo_license
      # Demo license oluştur
      fingerprint = generate_fingerprint
      license_key = generate_license(fingerprint, days: 30)
      
      @license_file.dirname.mkpath
      @license_file.write(license_key)
      
      puts "✅ Demo license created: #{@license_file}".colorize(:green)
      license_key
    end

    def check_license
      if @license_file.exist?
        license_key = @license_file.read.strip
        if validate_license(license_key)
          puts "✅ License valid".colorize(:green)
          return true
        else
          puts "❌ License invalid or expired".colorize(:red)
          return false
        end
      else
        puts "⚠️ No license found, creating demo license...".colorize(:yellow)
        create_demo_license
        true
      end
    end
  end
end