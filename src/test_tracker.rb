#!/usr/bin/env ruby
# frozen_string_literal: true

# Test suite for Phone Tracking System

require 'minitest/autorun'
require 'minitest/pride'
require_relative '../src/tracking'

class TestPhoneTracker < Minitest::Test
  def setup
    @tracker = AdvancedPhoneTracker.new
  end

  def test_security_manager
    security = SecurityManager.new
    data = { test: "data", timestamp: Time.now.to_i }
    
    encrypted = security.encrypt_data(data)
    refute_equal data.to_s, encrypted.to_s
    
    decrypted = security.decrypt_data(encrypted)
    assert_equal data[:test], decrypted[:test]
    assert_equal data[:timestamp], decrypted[:timestamp]
  end

  def test_blockchain_manager
    blockchain = BlockchainManager.new
    
    # Genesis block kontrolü
    assert_equal 1, blockchain.chain.length
    assert_equal 0, blockchain.chain.first[:index]
    
    # Yeni transaction ekle
    blockchain.new_transaction({ test: "data" })
    proof = blockchain.proof_of_work(blockchain.last_block[:proof])
    blockchain.new_block(proof)
    
    assert_equal 2, blockchain.chain.length
    assert_equal 1, blockchain.chain.last[:index]
  end

  def test_ml_models
    ml = MLModels.new
    
    # Konum tahmini testi
    historical_data = 10.times.map do |i|
      {
        lat: 41.0082 + rand(-0.001..0.001),
        lng: 28.9784 + rand(-0.001..0.001),
        timestamp: Time.now.to_i - i * 3600,
        speed: rand(0..100)
      }
    end
    
    prediction = ml.predict_location(historical_data)
    refute_nil prediction if historical_data.length >= 5
  end

  def test_database_manager
    db = DatabaseManager.new
    
    device_id = "TEST_DEVICE"
    location_data = {
      lat: 41.0082,
      lng: 28.9784,
      timestamp: Time.now.to_i,
      accuracy: 50.0,
      speed: 30.0
    }
    
    # Konum kaydetme testi
    db.save_location(device_id, location_data)
    
    # Geçmiş veri alma testi
    history = db.get_device_history(device_id, 1)
    assert history.length > 0
    assert_equal location_data[:lat], history.first[:lat]
  end

  def test_location_fusion
    fusion = LocationFusion.new
    
    sensor_locations = {
      gps_serial: { lat: 41.0082, lng: 28.9784, confidence: 0.9 },
      wifi_triangulation: { lat: 41.0081, lng: 28.9785, confidence: 0.6 },
      bluetooth_proximity: { lat: 41.0083, lng: 28.9783, confidence: 0.4 }
    }
    
    fused = fusion.fuse_locations(sensor_locations)
    refute_nil fused
    assert fused[:lat].between?(41.0080, 41.0085)
    assert fused[:lng].between?(28.9780, 28.9790)
  end

  def test_iot_manager
    iot = IoTManager.new
    
    # Mock testler - gerçek sensörler olmadan
    bluetooth_devices = iot.scan_bluetooth_devices
    assert bluetooth_devices.is_a?(Array)
    
    wifi_networks = iot.scan_wifi_networks
    assert wifi_networks.is_a?(Array)
  end

  def test_visualization_manager
    viz = VisualizationManager.new
    
    locations = 10.times.map do |i|
      {
        lat: 41.0082 + rand(-0.01..0.01),
        lng: 28.9784 + rand(-0.01..0.01),
        timestamp: Time.now.to_i - i * 60,
        speed: rand(0..100)
      }
    end
    
    device_id = "TEST_DEVICE"
    
    # Harita oluşturma testi
    map_file = viz.create_location_map(locations, device_id)
    refute_nil map_file
    assert File.exist?(map_file)
    
    # HTML rapor testi
    report_data = {
      statistics: { total_points: 10, avg_speed: 50.0 },
      daily_activity: [{ date: "2024-01-01", movements: 10 }],
      anomalies: [],
      sensor_usage: [{ sensor_type: "gps", count: 10 }]
    }
    
    html_file = viz.create_html_report(report_data, device_id)
    refute_nil html_file
    assert File.exist?(html_file)
    
    # Temizlik
    File.delete(map_file) if File.exist?(map_file)
    File.delete(html_file) if File.exist?(html_file)
  end

  def test_single_tracking_cycle
    location, anomalies, prediction = @tracker.run_single_tracking_cycle
    
    refute_nil location
    assert location[:lat].between?(40.0, 42.0)
    assert location[:lng].between?(28.0, 30.0)
    assert location[:timestamp].is_a?(Integer)
  end

  def test_demo_mode
    # Demo modu çalıştır (kısa versiyon)
    assert_output(/Demo modu tamamlandı/) do
      @tracker.run_demo_mode
    end
  end
end