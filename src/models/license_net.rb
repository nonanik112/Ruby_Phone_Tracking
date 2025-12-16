# frozen_string_literal: true

require 'json'
require 'digest'

module Core
  class LockedModel
    # Mock AI model sistemi - Gerçek uygulama için değiştirilmeli
    
    def initialize(license_key, license_manager)
      @license_key = license_key
      @license_manager = license_manager
      validate_license!
    end

    def validate_license!
      unless @license_manager.validate_license(@license_key)
        raise "Invalid or expired license key"
      end
    end

    def predict(fingerprint)
      # Mock tahmin - Gerçek AI modeli yerine geçici çözüm
      # Bu bir dummy implementasyondur, gerçek projede trained model kullanılmalı
      
      # Lisans geçerliyse mock prediction üret
      {
        validity_score: 0.95,
        confidence: 0.98,
        features: extract_features(fingerprint),
        prediction: "VALID_LICENSE",
        timestamp: Time.now.to_i
      }
    end

    def extract_features(fingerprint)
      # Basit feature extraction
      {
        fingerprint_hash: Digest::SHA256.hexdigest(fingerprint),
        length: fingerprint.length,
        entropy: calculate_entropy(fingerprint),
        pattern_score: calculate_pattern_score(fingerprint)
      }
    end

    def calculate_entropy(string)
      # Shannon entropy hesapla
      char_counts = Hash.new(0)
      string.each_char { |char| char_counts[char] += 1 }
      
      length = string.length.to_f
      entropy = 0.0
      
      char_counts.values.each do |count|
        probability = count / length
        entropy -= probability * Math.log2(probability) if probability > 0
      end
      
      entropy
    end

    def calculate_pattern_score(fingerprint)
      # Basit pattern analizi
      score = 0.0
      
      # Tekrar eden karakterler
      score += 0.2 if fingerprint.match?(/(.)\1{2,}/)
      
      # Sayı içerik oranı
      digit_ratio = fingerprint.count('0-9').to_f / fingerprint.length
      score += 0.3 if digit_ratio.between?(0.3, 0.7)
      
      # Harf içerik oranı
      letter_ratio = fingerprint.count('a-zA-Z').to_f / fingerprint.length
      score += 0.3 if letter_ratio.between?(0.3, 0.7)
      
      # Özel karakter oranı
      special_ratio = fingerprint.count('^a-zA-Z0-9').to_f / fingerprint.length
      score += 0.2 if special_ratio.between?(0.1, 0.3)
      
      [score, 1.0].min
    end
  end

  class LicenseNet
    # Mock neural network model
    def initialize(model_path = nil)
      @model_path = model_path || "src/models/license_net.rb"
      @weights = load_mock_weights
    end

    def load_mock_weights
      # Mock ağırlıklar - Gerçek projede trained model yüklenmeli
      {
        input_layer: Array.new(64) { rand(-1.0..1.0) },
        hidden_layer: Array.new(32) { rand(-1.0..1.0) },
        output_layer: Array.new(16) { rand(-1.0..1.0) },
        bias: rand(-0.5..0.5)
      }
    end

    def forward_pass(input_features)
      # Mock forward pass
      input_sum = input_features.sum
      hidden_output = Math.tanh(input_sum * @weights[:hidden_layer].sum)
      final_output = Math.sigmoid(hidden_output * @weights[:output_layer].sum + @weights[:bias])
      
      {
        output: final_output,
        confidence: [final_output, 0.95].min,
        features_used: input_features.length
      }
    end

    def save_model(path)
      # Mock model kaydetme
      model_data = {
        weights: @weights,
        timestamp: Time.now.to_i,
        version: "1.0.0",
        type: "mock_license_model"
      }
      
      File.write(path, JSON.pretty_generate(model_data))
    end

    def load_model(path)
      # Mock model yükleme
      if File.exist?(path)
        model_data = JSON.parse(File.read(path), symbolize_names: true)
        @weights = model_data[:weights]
        true
      else
        false
      end
    end
  end
end
