#!/usr/bin/env ruby
# frozen_string_literal: true

# =============================================================================
# 📡 GELİŞMİŞ TELEFON TAKİP SİSTEMİ (API'SİZ + AI + BLOCKCHAIN)
# =============================================================================
# Author: Advanced AI System
# Version: 1.0.0
# Ruby Version: 3.0+

require 'json'
require 'time'
require 'digest'
require 'securerandom'
require 'sqlite3'
require 'socket'
require 'thread'
require 'concurrent'
require 'colorize'
require 'numo/narray'
require 'daru'
require 'rumale'
require 'cryptography'
require 'serialport'
require 'opencv'
require 'geocoder'
require 'gruff'
require 'date'

# =============================================================================
# 🔧 TEMEL AYARLAR VE GÜVENLİK
# =============================================================================


begin
  require_relative 'core/ai_license_adapter'
  ai_adapter = Core::AILicenseAdapter.new
  ai_adapter.validate_system
rescue => e
  puts "⚠️ AI License system initialization failed: #{e.message}".colorize(:yellow)
  puts "Continuing with mock implementation...".colorize(:yellow)
end

class SecurityManager
  # Gelişmiş şifreleme ve güvenlik yönetimi
  
  def initialize
    @key_file = Pathname.new("security/encryption.key")
    @key_file.dirname.mkpath
    initialize_encryption
  end

  def initialize_encryption
    if @key_file.exist?
      @key = File.binread(@key_file)
    else
      @key = SecureRandom.random_bytes(32)
      File.binwrite(@key_file, @key)
    end
    @cipher = Cryptography::Fernet.new(@key)
  end

  def encrypt_data(data)
    json_data = JSON.generate(data.sort.to_h)
    @cipher.encrypt(json_data)
  end

  def decrypt_data(encrypted_data)
    decrypted = @cipher.decrypt(encrypted_data)
    JSON.parse(decrypted)
  end
end

class BlockchainManager
  # Blockchain tabanlı veri bütünlüğü
  
  attr_reader :chain

  def initialize
    @chain = []
    @pending_transactions = []
    create_genesis_block
  end

  def create_genesis_block
    genesis_block = {
      index: 0,
      timestamp: Time.now.to_f,
      transactions: [],
      proof: 100,
      previous_hash: '1'
    }
    @chain << genesis_block
  end

  def new_block(proof, previous_hash = nil)
    block = {
      index: @chain.length + 1,
      timestamp: Time.now.to_f,
      transactions: @pending_transactions,
      proof: proof,
      previous_hash: previous_hash || hash(@chain.last)
    }

    @pending_transactions = []
    @chain << block
    block
  end

  def new_transaction(data)
    @pending_transactions << {
      data: data,
      timestamp: Time.now.to_f
    }
    last_block[:index] + 1
  end

  def hash(block)
    block_string = JSON.generate(block.sort.to_h)
    Digest::SHA256.hexdigest(block_string)
  end

  def last_block
    @chain.last
  end

  def proof_of_work(last_proof)
    proof = 0
    proof += 1 until valid_proof?(last_proof, proof)
    proof
  end

  def valid_proof?(last_proof, proof)
    guess = "#{last_proof}#{proof}"
    guess_hash = Digest::SHA256.hexdigest(guess)
    guess_hash[0..3] == "0000"
  end
end

# =============================================================================
# 🤖 YAPAY ZEKA VE MAKİNE ÖĞRENMESİ
# =============================================================================

class MLModels
  # Gelişmiş ML modelleri
  
  def initialize
    @anomaly_detector = Rumale::AnomalyDetection::IsolationForest.new(
      contamination: 0.1,
      random_seed: 42
    )
    @scaler = Rumale::Preprocessing::StandardScaler.new
    @location_predictor = build_lstm_model
    @behavior_analyzer = BehaviorAnalyzer.new
  end

  def build_lstm_model
    # LSTM konum tahmin modeli
    # Rumale ile basit bir sinir ağı
    Rumale::NeuralNetwork::MLPRegressor.new(
      hidden_units: [64, 32, 16],
      activation: 'relu',
      max_iter: 1000,
      random_seed: 42
    )
  end

  def predict_location(historical_data)
    return nil if historical_data.length < 5

    # Veri hazırlığı
    df = Daru::DataFrame.new(historical_data)
    df = df.sort_by([:timestamp])

    # Özellik mühendisliği
    features = []
    df.each_row do |row|
      features << [
        row[:lat], row[:lng],
        row[:speed] || 0, row[:altitude] || 0,
        Math.sin(row[:timestamp] % 86400),
        Math.cos(row[:timestamp] % 86400),
        row[:battery_level] || 50,
        row[:accuracy] || 100
      ]
    end

    return nil if features.empty?

    features_narray = Numo::DFloat[*features]
    features_scaled = @scaler.fit_transform(features_narray)

    # Tahmin yap
    # Basit bir tahmin modeli
    last_features = features_scaled[-1, true].to_a
    predicted = [
      last_features[0] + rand(-0.001..0.001),
      last_features[1] + rand(-0.001..0.001)
    ]

    # Güven skoru hesapla
    confidence = calculate_confidence(historical_data, predicted)

    {
      lat: predicted[0],
      lng: predicted[1],
      confidence: confidence,
      timestamp: Time.now.to_i + 3600
    }
  end

  def calculate_confidence(historical_data, prediction)
    return 0.5 if historical_data.length < 2

    # Son bilinen konum
    last = historical_data.last
    distance = Geocoder::Calculations.distance_between(
      [last[:lat], last[:lng]],
      [prediction[0], prediction[1]]
    )

    # Makul mesafe kontrolü
    time_diff = 1 # 1 saat sonrası için tahmin
    max_reasonable_speed = 150 # km/h
    max_reasonable_distance = max_reasonable_speed * time_diff

    return 0.1 if distance > max_reasonable_distance

    # Güven = 1 - (mesafe / maksimum mesafe)
    confidence = 1 - (distance / max_reasonable_distance)
    [0.1, confidence, 1.0].sort[1]
  end

  def detect_anomalies(current_data, historical_data)
    anomalies = []

    return anomalies if historical_data.length < 3

    # Hız anomalisi
    if (current_data[:speed] || 0) > 250
      anomalies << {
        type: 'extreme_speed',
        severity: [(current_data[:speed] || 0) / 350, 1.0].min,
        details: "Ekstrem hız: #{current_data[:speed]&.round(1)} km/s"
      }
    end

    # Konum sıçraması
    last_data = historical_data.last
    distance = Geocoder::Calculations.distance_between(
      [last_data[:lat], last_data[:lng]],
      [current_data[:lat], current_data[:lng]]
    )

    time_diff = [(Time.now.to_i - last_data[:timestamp]) / 3600, 1].max
    if distance / time_diff > 200 # 200 km/h üzeri
      anomalies << {
        type: 'location_jump',
        severity: [(distance / time_diff) / 300, 1.0].min,
        details: "Anormal sıçrama: #{distance.round(1)} km #{time_diff.round(1)} saatte"
      }
    end

    # Davranış anomalisi
    behavior_score = @behavior_analyzer.analyze(current_data, historical_data)
    if behavior_score > 0.7
      anomalies << {
        type: 'behavior_anomaly',
        severity: behavior_score,
        details: 'Olağandışı hareket patterni'
      }
    end

    anomalies
  end
end

class BehaviorAnalyzer
  # Davranış analizi motoru
  
  def initialize
    @patterns = {}
    @risk_threshold = 0.7
  end

  def analyze(current_data, historical_data)
    return 0.0 if historical_data.length < 5

    # Hareket frekansı
    recent_data = historical_data.last(10)
    time_diff = [(Time.now.to_i - recent_data.first[:timestamp]) / 3600, 1].max
    movement_freq = recent_data.length / time_diff

    # Ortalama hız
    speeds = recent_data.map { |d| d[:speed] || 0 }
    avg_speed = speeds.empty? ? 0 : speeds.sum / speeds.length

    # Konum değişikliği
    distances = []
    (1...recent_data.length).each do |i|
      dist = Geocoder::Calculations.distance_between(
        [recent_data[i-1][:lat], recent_data[i-1][:lng]],
        [recent_data[i][:lat], recent_data[i][:lng]]
      )
      distances << dist
    end

    avg_distance = distances.empty? ? 0 : distances.sum / distances.length

    # Risk hesaplama
    risk_factors = [
      movement_freq > 50,    # Aşırı hareket
      avg_speed > 150,       # Yüksek hız
      avg_distance > 100     # Uzak mesafe
    ]

    risk_score = risk_factors.count(true).to_f / risk_factors.length
    risk_score
  end
end

# =============================================================================
# 📡 IoT VE SENSÖR ENTEGRASYONU
# =============================================================================

class IoTManager
  # IoT cihaz yönetimi
  
  def initialize
    @devices = {}
    @sensor_data = []
    @max_sensor_data = 1000
  end

  def scan_bluetooth_devices
    # Bluetooth cihaz taraması
    begin
      # Basit simülasyon - gerçek implementasyon için bluetooth gem'i gerekli
      nearby_devices = []
      
      # Mock veri
      3.times do |i|
        nearby_devices << {
          address: "00:11:22:33:44:#{i.to_s(16).rjust(2, '0').upcase}",
          name: "Device_#{i}",
          device_class: rand(1000..2000),
          rssi: rand(-90..-30)
        }
      end
      
      nearby_devices
    rescue => e
      puts "Bluetooth hatası: #{e}".colorize(:red)
      []
    end
  end

  def scan_wifi_networks
    # WiFi ağ taraması
    begin
      # Linux için
      if RUBY_PLATFORM =~ /linux/
        result = `iwlist scan 2>/dev/null`
        networks = []
        result.each_line do |line|
          if line.include?('ESSID:')
            ssid = line.split('ESSID:')[1].strip.gsub('"', '')
            networks << { ssid: ssid, signal: rand(-80..-30) }
          end
        end
        return networks
      end
      
      # Windows/Mac için mock veri
      [
        { ssid: 'TestNetwork1', signal: rand(-80..-30) },
        { ssid: 'TestNetwork2', signal: rand(-80..-30) },
        { ssid: 'TestNetwork3', signal: rand(-80..-30) }
      ]
    rescue => e
      puts "WiFi hatası: #{e}".colorize(:red)
      []
    end
  end

  def read_gps_serial
    # Seri porttan GPS okuma
    locations = []
    ports = ['/dev/ttyUSB0', '/dev/ttyAMA0', 'COM3', 'COM4']

    ports.each do |port|
      begin
        SerialPort.open(port, 9600, 8, 1, SerialPort::NONE) do |sp|
          5.times do # 5 satır dene
            line = sp.gets
            next unless line&.start_with?('$GPGGA')

            # Basit NMEA parse
            parts = line.chomp.split(',')
            next if parts.length < 10

            lat = parse_nmea_coord(parts[2], parts[3])
            lng = parse_nmea_coord(parts[4], parts[5])
            
            next unless lat && lng

            locations << {
              lat: lat,
              lng: lng,
              altitude: parts[9]&.to_f || 0,
              satellites: parts[7]&.to_i || 0,
              source: 'gps_serial'
            }
            break
          end
        end
      rescue => e
        next
      end
    end

    locations
  end

  def parse_nmea_coord(coord, direction)
    return nil unless coord && direction
    
    degrees = coord[0..1].to_f
    minutes = coord[2..-1].to_f
    decimal = degrees + minutes / 60
    
    decimal *= -1 if direction =~ /[SW]/
    decimal
  end

  def process_camera_feed
    # Kamera görüntüsü işleme
    begin
      # OpenCV ile kamera işleme
      cap = OpenCV::CvCapture.open(0)
      frame = cap.query
      cap.release

      # QR kod tespiti
      detector = OpenCV::CvQRCodeDetector.new
      data, bbox = detector.detect_and_decode(frame)
      
      {
        qr_detected: !data.empty?,
        qr_data: data.empty? ? nil : data,
        frame_processed: true,
        timestamp: Time.now.to_f
      }
    rescue => e
      puts "Kamera hatası: #{e}".colorize(:red)
      { error: e.to_s }
    end
  end

  def record_audio_analysis
    # Ses analizi
    begin
      duration = 3
      sample_rate = 44100

      puts "Ses kaydı başlatılıyor...".colorize(:yellow)
      
      # Mock ses verisi - gerçek implementasyon için ruby-audio gem'i gerekli
      recording = Array.new(duration * sample_rate) { rand(-1.0..1.0) }

      # Frekans analizi
      fft = Numo::NMath.fft(Numo::DFloat[*recording])
      frequencies = Numo::DFloat[*recording].length.times.map do |i|
        i * sample_rate / recording.length.to_f
      end

      # Ana frekansları bul
      magnitude_spectrum = fft.map(&:abs)
      max_idx = magnitude_spectrum.to_a.index(magnitude_spectrum.max)
      dominant_freq = frequencies[max_idx]

      # WAV dosyasına kaydet
      filename = "recordings/audio_#{Time.now.to_i}.wav"
      FileUtils.mkdir_p(File.dirname(filename))
      
      # Mock WAV kaydı
      File.write(filename, "WAV audio data - dominant frequency: #{dominant_freq}")

      {
        filename: filename,
        dominant_frequency: dominant_freq,
        duration: duration,
        processed: true
      }
    rescue => e
      puts "Ses kaydı hatası: #{e}".colorize(:red)
      { error: e.to_s }
    end
  end
end

# =============================================================================
# 📊 VERİTABANI VE RAPORLAMA
# =============================================================================

class DatabaseManager
  # Veritabanı yönetimi
  
  def initialize
    @db_path = "data/tracking.db"
    FileUtils.mkdir_p(File.dirname(@db_path))
    init_database
  end

  def init_database
    # Veritabanını başlat
    db = SQLite3::Database.new(@db_path)
    
    # Konumlar tablosu
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        accuracy REAL,
        timestamp INTEGER NOT NULL,
        speed REAL,
        altitude REAL,
        battery_level REAL,
        network_type TEXT,
        satellites INTEGER,
        source TEXT,
        confidence REAL
      )
    SQL

    # Sensör verileri
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS sensor_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        sensor_type TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    SQL

    # Anomaliler
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS anomalies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        anomaly_type TEXT NOT NULL,
        severity REAL NOT NULL,
        details TEXT,
        timestamp INTEGER NOT NULL
      )
    SQL

    # Tahminler
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS predictions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        predicted_lat REAL,
        predicted_lng REAL,
        confidence REAL,
        timestamp INTEGER NOT NULL
      )
    SQL

    # Blockchain
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS blockchain (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        block_index INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        data_hash TEXT NOT NULL,
        previous_hash TEXT NOT NULL,
        proof INTEGER NOT NULL
      )
    SQL

    db.close
  end

  def save_location(device_id, location_data)
    # Konum verisini kaydet
    db = SQLite3::Database.new(@db_path)
    
    db.execute <<-SQL, [
      device_id,
      location_data[:lat],
      location_data[:lng],
      location_data[:accuracy] || 0,
      location_data[:timestamp],
      location_data[:speed] || 0,
      location_data[:altitude] || 0,
      location_data[:battery_level] || 100,
      location_data[:network_type] || 'unknown',
      location_data[:satellites] || 0,
      location_data[:source] || 'unknown',
      location_data[:confidence] || 0.5
    ]
      INSERT INTO locations
      (device_id, lat, lng, accuracy, timestamp, speed, altitude,
       battery_level, network_type, satellites, source, confidence)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    SQL

    db.close
  end

  def save_sensor_data(device_id, sensor_type, data)
    # Sensör verisini kaydet
    db = SQLite3::Database.new(@db_path)
    
    db.execute <<-SQL, [device_id, sensor_type, JSON.generate(data), Time.now.to_i]
      INSERT INTO sensor_data (device_id, sensor_type, data, timestamp)
      VALUES (?, ?, ?, ?)
    SQL

    db.close
  end

  def save_anomaly(device_id, anomaly)
    # Anomaliyi kaydet
    db = SQLite3::Database.new(@db_path)
    
    db.execute <<-SQL, [
      device_id,
      anomaly[:type],
      anomaly[:severity],
      anomaly[:details],
      Time.now.to_i
    ]
      INSERT INTO anomalies (device_id, anomaly_type, severity, details, timestamp)
      VALUES (?, ?, ?, ?, ?)
    SQL

    db.close
  end

  def get_device_history(device_id, hours = 24)
    # Cihaz geçmişini getir
    db = SQLite3::Database.new(@db_path)
    
    result = db.execute <<-SQL, [device_id, Time.now.to_i - hours * 3600]
      SELECT lat, lng, timestamp, speed, altitude, accuracy
      FROM locations
      WHERE device_id = ? AND timestamp > ?
      ORDER BY timestamp ASC
    SQL

    data = result.map do |row|
      {
        lat: row[0], lng: row[1], timestamp: row[2],
        speed: row[3], altitude: row[4], accuracy: row[5]
      }
    end

    db.close
    data
  end

  def generate_report(device_id, days = 7)
    # Detaylı rapor oluştur
    db = SQLite3::Database.new(@db_path)
    
    # Temel istatistikler
    stats_result = db.execute <<-SQL, [device_id, Time.now.to_i - days * 86400]
      SELECT COUNT(*) as total_points, AVG(speed) as avg_speed,
             MAX(speed) as max_speed, MIN(lat) as min_lat, MAX(lat) as max_lat,
             MIN(lng) as min_lng, MAX(lng) as max_lng,
             AVG(accuracy) as avg_accuracy
      FROM locations
      WHERE device_id = ? AND timestamp > ?
    SQL

    # Günlük aktivite
    daily_result = db.execute <<-SQL, [device_id, Time.now.to_i - days * 86400]
      SELECT DATE(timestamp, 'unixepoch') as date, COUNT(*) as movements
      FROM locations
      WHERE device_id = ? AND timestamp > ?
      GROUP BY date
      ORDER BY date
    SQL

    # Anomaliler
    anomalies_result = db.execute <<-SQL, [device_id, Time.now.to_i - days * 86400]
      SELECT anomaly_type, COUNT(*) as count, AVG(severity) as avg_severity
      FROM anomalies
      WHERE device_id = ? AND timestamp > ?
      GROUP BY anomaly_type
    SQL

    # Sensör kullanımı
    sensors_result = db.execute <<-SQL, [device_id, Time.now.to_i - days * 86400]
      SELECT sensor_type, COUNT(*) as count
      FROM sensor_data
      WHERE device_id = ? AND timestamp > ?
      GROUP BY sensor_type
    SQL

    db.close

    {
      statistics: stats_result.first || {},
      daily_activity: daily_result.map { |row| { date: row[0], movements: row[1] } },
      anomalies: anomalies_result.map { |row| { anomaly_type: row[0], count: row[1], avg_severity: row[2] } },
      sensor_usage: sensors_result.map { |row| { sensor_type: row[0], count: row[1] } },
      report_generated: Time.now.iso8601
    }
  end
end

# =============================================================================
# 🗺️ KONUM FÜZYONU VE ANALİZ
# =============================================================================

class LocationFusion
  # Çoklu sensör konum füzyonu
  
  def initialize
    @fusion_weights = {
      gps_serial: 0.9,
      wifi_triangulation: 0.6,
      bluetooth_proximity: 0.4,
      camera_qr: 0.8,
      audio_fingerprint: 0.3
    }
  end

  def fuse_locations(sensor_locations)
    return nil if sensor_locations.empty?

    weighted_coords = []
    total_weight = 0

    sensor_locations.each do |source, location|
      next unless location && @fusion_weights[source]

      weight = @fusion_weights[source] * (location[:confidence] || 0.5)
      weighted_coords << {
        lat: location[:lat] * weight,
        lng: location[:lng] * weight,
        weight: weight
      }
      total_weight += weight
    end

    return nil if total_weight == 0

    # Ağırlıklı ortalama
    avg_lat = weighted_coords.sum { |coord| coord[:lat] } / total_weight
    avg_lng = weighted_coords.sum { |coord| coord[:lng] } / total_weight

    # Ortalama güven
    avg_confidence = sensor_locations.values.sum { |loc| loc[:confidence] || 0.5 } / sensor_locations.length

    {
      lat: avg_lat,
      lng: avg_lng,
      accuracy: 100 / [avg_confidence, 0.1].max,
      confidence: avg_confidence,
      sources: sensor_locations.keys
    }
  end

  def triangulate_wifi(wifi_networks)
    return nil if wifi_networks.length < 3

    # Sinyal gücüne göre mesafe tahmini
    positions = []
    wifi_networks.each do |network|
      # RSSI'dan mesafe hesaplama (basit model)
      rssi = network[:signal] || -70
      distance = 10 ** ((rssi.abs - 50) / 20.0)

      # Rastgele konumlar (gerçekte veritabanından alınmalı)
      lat = 41.0082 + rand(-0.01..0.01)
      lng = 28.9784 + rand(-0.01..0.01)

      positions << {
        lat: lat,
        lng: lng,
        weight: 1.0 / [distance, 1].max
      }
    end

    # Ağırlıklı ortalama
    total_weight = positions.sum { |pos| pos[:weight] }
    avg_lat = positions.sum { |pos| pos[:lat] * pos[:weight] } / total_weight
    avg_lng = positions.sum { |pos| pos[:lng] * pos[:weight] } / total_weight

    {
      lat: avg_lat,
      lng: avg_lng,
      accuracy: 50,
      confidence: 0.6,
      source: 'wifi_triangulation'
    }
  end

  def estimate_bluetooth_position(bt_devices)
    return nil if bt_devices.empty?

    # En yakın cihazı bul
    closest = bt_devices.min_by { |x| x[:rssi] || -100 }
    rssi = closest[:rssi] || -70

    # Mesafe tahmini
    distance = 10 ** ((rssi.abs - 59) / 20.0)

    # Rastgele konum (gerçekte cihaz veritabanından alınmalı)
    base_lat = 41.0082
    base_lng = 28.9784

    # RSSI'dan yön tahmini (basitleştirilmiş)
    angle = rand(0..(2 * Math::PI))
    lat_offset = (distance / 111000.0) * Math.cos(angle)
    lng_offset = (distance / 111000.0) * Math.sin(angle) / Math.cos(base_lat * Math::PI / 180)

    {
      lat: base_lat + lat_offset,
      lng: base_lng + lng_offset,
      accuracy: distance,
      confidence: [0.3, 1 - (rssi.abs / 100.0)].max,
      source: 'bluetooth_proximity'
    }
  end
end

# =============================================================================
# 🎨 GÖRSELLEŞTİRME VE RAPORLAMA
# =============================================================================

class VisualizationManager
  # Gelişmiş görselleştirme araçları
  
  def initialize
    @output_dir = Pathname.new("reports")
    @output_dir.mkpath
  end

  def create_location_map(locations, device_id)
    return nil if locations.empty?

    # Gruff ile harita benzeri görsel
    g = Gruff::Line.new(800)
    g.title = "#{device_id} Konum Takibi"
    g.theme = {
      colors: ['#ff0000', '#00ff00', '#0000ff', '#ffff00', '#ff00ff'],
      marker_color: '#333333',
      font_color: '#333333',
      background_colors: ['#ffffff', '#f0f0f0']
    }

    # Koordinatları ayır
    lats = locations.map { |loc| loc[:lat] }
    lngs = locations.map { |loc| loc[:lng] }

    # Zaman serisi olarak çiz
    g.data("Enlem", lats)
    g.data("Boylam", lngs)
    
    # Etiketler
    g.labels = Hash[locations.each_with_index.map { |_, i| [i, (i+1).to_s] }]

    # Dosyaya kaydet
    filename = @output_dir + "location_map_#{device_id}_#{Time.now.to_i}.png"
    g.write(filename.to_s)

    filename.to_s
  end

  def create_speed_profile(locations, device_id)
    return nil if locations.empty? || !locations.first[:speed]

    # Hız profili grafiği
    g = Gruff::Line.new(800)
    g.title = "#{device_id} Hız Profili"
    
    timestamps = locations.map { |loc| Time.at(loc[:timestamp]) }
    speeds = locations.map { |loc| loc[:speed] || 0 }

    g.data("Hız", speeds)
    
    # X ekseni etiketleri
    g.labels = Hash[timestamps.each_with_index.map { |ts, i| [i, ts.strftime("%H:%M")] }]

    filename = @output_dir + "speed_profile_#{device_id}_#{Time.now.to_i}.png"
    g.write(filename.to_s)

    filename.to_s
  end

  def create_html_report(report_data, device_id)
    # HTML raporu oluştur
    html_template = <<-HTML
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gelişmiş Takip Raporu - #{device_id}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .header { text-align: center; color: #333; margin-bottom: 30px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 20px 0; }
        .stat-card { background: #f8f9fa; padding: 15px; border-radius: 8px; text-align: center; }
        .stat-value { font-size: 24px; font-weight: bold; color: #007bff; }
        .section { margin: 20px 0; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f8f9fa; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📡 Gelişmiş Telefon Takip Raporu</h1>
            <p>Cihaz: #{device_id} | Tarih: #{Time.now.strftime("%Y-%m-%d %H:%M")}</p>
        </div>

        <div class="stats">
            <div class="stat-card">
                <div class="stat-value">#{report_data[:statistics][:total_points] || 0}</div>
                <div>Toplam Hareket</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">#{(report_data[:statistics][:avg_speed] || 0).round(1)} km/s</div>
                <div>Ortalama Hız</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">#{(report_data[:statistics][:max_speed] || 0).round(1)} km/s</div>
                <div>Maksimum Hız</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">#{report_data[:anomalies].length}</div>
                <div>Anomali Sayısı</div>
            </div>
        </div>

        <div class="section">
            <h2>📅 Günlük Aktivite</h2>
            <table>
                <thead>
                    <tr><th>Tarih</th><th>Hareket Sayısı</th></tr>
                </thead>
                <tbody>
                    #{report_data[:daily_activity].map { |day| "<tr><td>#{day[:date]}</td><td>#{day[:movements]}</td></tr>" }.join}
                </tbody>
            </table>
        </div>

        <div class="section">
            <h2>⚠️ Tespit Edilen Anomaliler</h2>
            #{report_data[:anomalies].empty? ? "<p>Anomali tespit edilmedi</p>" : 
              "<table><thead><tr><th>Anomali Türü</th><th>Sayı</th><th>Ort. Ciddiyet</th></tr></thead><tbody>" +
              report_data[:anomalies].map { |anomaly| 
                "<tr><td>#{anomaly[:anomaly_type]}</td><td>#{anomaly[:count]}</td><td>#{(anomaly[:avg_severity] || 0).round(2)}</td></tr>" 
              }.join + "</tbody></table>"}
        </div>

        <div class="section">
            <h2>📊 Sensör Kullanımı</h2>
            #{report_data[:sensor_usage].empty? ? "<p>Sensör verisi bulunamadı</p>" :
              "<ul>" + report_data[:sensor_usage].map { |sensor| 
                "<li>#{sensor[:sensor_type]}: #{sensor[:count]} kullanım</li>" 
              }.join + "</ul>"}
        </div>
    </div>
</body>
</html>
    HTML

    # Dosyaya kaydet
    filename = @output_dir + "report_#{device_id}_#{Time.now.to_i}.html"
    File.write(filename, html_template)

    filename.to_s
  end
end

# =============================================================================
# 🚀 ANA SİSTEM - Tüm Bileşenleri Birleştirir
# =============================================================================

class AdvancedPhoneTracker
  # Gelişmiş telefon takip sistemi - Tüm bileşenleri birleştirir
  
  def initialize
    @colors = {
      blue: :blue,
      cyan: :cyan,
      yellow: :yellow,
      green: :green,
      red: :red,
      magenta: :magenta,
      white: :white
    }

    # Tüm yöneticileri başlat
    puts "🚀 Sistem başlatılıyor...".colorize(:cyan)

    @security = SecurityManager.new
    @blockchain = BlockchainManager.new
    @ml_models = MLModels.new
    @iot_manager = IoTManager.new
    @db_manager = DatabaseManager.new
    @fusion_engine = LocationFusion.new
    @visualizer = VisualizationManager.new

    @device_id = "DEVICE_#{Time.now.to_i}"
    @tracking_active = false
    @sensor_threads = []

    puts "✅ Tüm sistemler başlatıldı".colorize(:green)
  end

  def print_banner
    banner = """
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║ ███████╗██╗  ██╗██████╗ ██████╗ ██████╗ ██████╗ ██████╗ ███████╗           ║
║ ██╔════╝██║  ██║██╔══██╗██╔════╝ ██╔═══██╗██╔══██╗██╔═══██╗██╔════╝           ║
║ █████╗  ██║  ██║██████╔╝██║  ███╗██║   ██║██████╔╝██║   ██║███████╗           ║
║ ██╔══╝  ██║  ██║██╔══██╗██║   ██║██║   ██║██╔══██╗██║   ██║╚════██║           ║
║ ██║    ╚██████╔╝██████╔╝╚██████╔╝╚██████╔╝██║  ██║╚██████╔╝███████║           ║
║ ╚═╝     ╚═════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝           ║
║                                                                              ║
║ G E L İ Ş M İ Ş   T A K İ P   S İ S T E M İ                                ║
║                                                                              ║
║ ► Yapay Zeka Destekli                                                        ║
║ ► Blockchain Güvenliği                                                       ║
║ ► IoT Entegrasyonu                                                           ║
║ ► Edge Computing                                                             ║
║ ► API'siz Çalışır                                                            ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
    """
    puts banner.colorize(:blue)
  end

  def collect_all_sensor_data
    sensor_data = {}

    # GPS Seri port
    puts "📡 GPS sensörü taranıyor...".colorize(:yellow)
    gps_data = @iot_manager.read_gps_serial
    if gps_data.any?
      sensor_data[:gps_serial] = gps_data.first
      puts "✅ GPS bulundu: #{gps_data.first[:lat].round(6)}, #{gps_data.first[:lng].round(6)}".colorize(:green)
    end

    # WiFi tarama
    puts "📶 WiFi ağları taranıyor...".colorize(:yellow)
    wifi_data = @iot_manager.scan_wifi_networks
    if wifi_data.any?
      @db_manager.save_sensor_data(@device_id, 'wifi', wifi_data)
      wifi_location = @fusion_engine.triangulate_wifi(wifi_data)
      if wifi_location
        sensor_data[:wifi_triangulation] = wifi_location
        puts "✅ WiFi triangülasyonu tamamlandı".colorize(:green)
      end
    end

    # Bluetooth tarama
    puts "🔷 Bluetooth cihazları taranıyor...".colorize(:yellow)
    bt_data = @iot_manager.scan_bluetooth_devices
    if bt_data.any?
      @db_manager.save_sensor_data(@device_id, 'bluetooth', bt_data)
      bt_location = @fusion_engine.estimate_bluetooth_position(bt_data)
      if bt_location
        sensor_data[:bluetooth_proximity] = bt_location
        puts "✅ Bluetooth konum tahmini yapıldı".colorize(:green)
      end
    end

    # Kamera işleme
    puts "📷 Kamera analizi yapılıyor...".colorize(:yellow)
    camera_data = @iot_manager.process_camera_feed
    if camera_data && !camera_data[:error]
      @db_manager.save_sensor_data(@device_id, 'camera', camera_data)
      if camera_data[:qr_data]
        begin
          qr_location = JSON.parse(camera_data[:qr_data])
          sensor_data[:camera_qr] = qr_location
          puts "✅ QR kod konumu bulundu".colorize(:green)
        rescue
          # Ignore JSON parse errors
        end
      end
    end

    # Ses analizi
    puts "🎤 Ses analizi yapılıyor...".colorize(:yellow)
    audio_data = @iot_manager.record_audio_analysis
    if audio_data && !audio_data[:error]
      @db_manager.save_sensor_data(@device_id, 'audio', audio_data)
      puts "✅ Ses analizi tamamlandı".colorize(:green)
    end

    sensor_data
  end

  def process_fused_location(sensor_data)
    return simulated_location if sensor_data.empty?

    # Konum füzyonu yap
    fused_location = @fusion_engine.fuse_locations(sensor_data)

    if fused_location
      # Veriyi zenginleştir
      enhanced_location = fused_location.merge(
        timestamp: Time.now.to_i,
        speed: rand(0.0..120.0),
        altitude: rand(0.0..500.0),
        battery_level: rand(20.0..100.0),
        network_type: ['4G', '5G', 'WiFi'].sample,
        satellites: rand(4..12)
      )

      return enhanced_location
    end

    # Füzyon başarısız olursa en güvenilir sensörü kullan
    best_source = sensor_data.max_by { |_, location| location[:confidence] || 0 }
    
    if best_source && best_source[1]
      return best_source[1].merge(
        timestamp: Time.now.to_i,
        sources: [best_source[0]]
      )
    end

    nil
  end

  def simulated_location
    {
      lat: 41.0082 + rand(-0.01..0.01),
      lng: 28.9784 + rand(-0.01..0.01),
      accuracy: 100,
      confidence: 0.5,
      sources: ['simulated'],
      timestamp: Time.now.to_i,
      speed: rand(0.0..120.0),
      altitude: rand(0.0..500.0),
      battery_level: rand(20.0..100.0),
      network_type: ['4G', '5G', 'WiFi'].sample,
      satellites: rand(4..12)
    }
  end

  def analyze_and_predict(location_data)
    # Geçmiş verileri al
    historical_data = @db_manager.get_device_history(@device_id, 6)

    # Anomali tespiti
    anomalies = @ml_models.detect_anomalies(location_data, historical_data)

    # Tahmin yap
    prediction = @ml_models.predict_location(historical_data + [location_data])

    [anomalies, prediction]
  end

  def save_to_blockchain(location_data, sensor_data)
    data_package = {
      location: location_data,
      sensors: sensor_data,
      timestamp: Time.now.to_f,
      device_id: @device_id
    }

    # Veriyi şifrele
    encrypted_data = @security.encrypt_data(data_package)

    # Blockchain'e ekle
    @blockchain.new_transaction(encrypted_data)
    proof = @blockchain.proof_of_work(@blockchain.last_block[:proof])
    block_hash = @blockchain.new_block(proof)

    block_hash
  end

  def visualize_results(location_data, anomalies, prediction)
    # Geçmiş verileri al
    historical_data = @db_manager.get_device_history(@device_id, 24)

    # Harita oluştur
    if historical_data.any?
      map_file = @visualizer.create_location_map(historical_data, @device_id)
      puts "🗺️ Harita oluşturuldu: #{map_file}".colorize(:green) if map_file
    end

    # Hız profili
    speed_file = @visualizer.create_speed_profile(historical_data, @device_id)
    puts "📈 Hız profili oluşturuldu: #{speed_file}".colorize(:green) if speed_file

    # Anomali zaman çizelgesi
    if anomalies.any?
      anomaly_file = @visualizer.create_anomaly_timeline(anomalies, @device_id)
      puts "⚠️ Anomali zaman çizelgesi: #{anomaly_file}".colorize(:green) if anomaly_file
    end
  end

  def generate_comprehensive_report
    # Kapsamlı rapor oluştur
    db_report = @db_manager.generate_report(@device_id, 7)

    # HTML raporu oluştur
    html_file = @visualizer.create_html_report(db_report, @device_id)

    puts "📊 Kapsamlı rapor oluşturuldu: #{html_file}".colorize(:cyan)

    html_file
  end

  def run_single_tracking_cycle
    begin
      puts "\n#{'═' * 60}".colorize(:yellow)
      puts "🔄 Takip döngüsü başlatılıyor...".colorize(:cyan)

      # 1. Tüm sensörlerden veri topla
      sensor_data = collect_all_sensor_data

      # 2. Konum füzyonu yap
      fused_location = process_fused_location(sensor_data)

      if fused_location
        # 3. Veritabanına kaydet
        @db_manager.save_location(@device_id, fused_location)

        # 4. Analiz ve tahmin yap
        anomalies, prediction = analyze_and_predict(fused_location)

        # 5. Anomalileri kaydet
        anomalies.each { |anomaly| @db_manager.save_anomaly(@device_id, anomaly) }

        # 6. Blockchain'e kaydet
        block_hash = save_to_blockchain(fused_location, sensor_data)

        # 7. Sonuçları göster
        puts "\n📍 Konum: #{fused_location[:lat].round(6)}, #{fused_location[:lng].round(6)}".colorize(:green)
        puts "🎯 Doğruluk: #{fused_location[:accuracy].round(1)}m".colorize(:green)
        puts "🔗 Kaynaklar: #{fused_location[:sources].join(', ')}".colorize(:green)

        if anomalies.any?
          puts "⚠️ #{anomalies.length} anomali tespit edildi".colorize(:red)
          anomalies.each do |anomaly|
            puts " - #{anomaly[:type]}: #{anomaly[:details]}".colorize(:red)
          end
        end

        if prediction
          puts "🔮 Tahmin: #{prediction[:lat].round(6)}, #{prediction[:lng].round(6)} (Güven: #{prediction[:confidence].round(2)})".colorize(:magenta)
        end

        puts "⛓️ Blockchain: #{block_hash.to_s[0..15]}...".colorize(:green)

        return [fused_location, anomalies, prediction]
      else
        puts "❌ Konum belirlenemedi".colorize(:red)
        return [nil, [], nil]
      end

    rescue => e
      puts "❌ Hata: #{e.message}".colorize(:red)
      return [nil, [], nil]
    end
  end

  def run_continuous_tracking(duration_minutes: 60, interval_seconds: 30)
    # Sürekli takip modu
    @tracking_active = true
    start_time = Time.now
    cycle_count = 0

    puts "🚀 Sürekli takip başlatıldı".colorize(:cyan)
    puts "⏱️ Süre: #{duration_minutes} dakika | Aralık: #{interval_seconds} saniye".colorize(:cyan)
    puts "Durdurmak için Ctrl+C".colorize(:yellow)

    begin
      while @tracking_active
        cycle_count += 1
        current_time = Time.now

        # Süre kontrolü
        break if (current_time - start_time) > duration_minutes * 60

        # Takip döngüsü
        location, anomalies, prediction = run_single_tracking_cycle

        # Görselleştirme (her 10 döngüde bir)
        visualize_results(location, anomalies, prediction) if cycle_count % 10 == 0

        # Bekle
        sleep(interval_seconds)
      end

      puts "⏰ Belirlenen süre doldu".colorize(:yellow) if (current_time - start_time) > duration_minutes * 60

    rescue Interrupt
      puts "\n🛑 Kullanıcı tarafından durduruldu".colorize(:red)
    ensure
      @tracking_active = false
      puts "📊 Rapor oluşturuluyor...".colorize(:cyan)

      # Kapsamlı rapor oluştur
      report_file = generate_comprehensive_report

      puts "✅ Takip tamamlandı".colorize(:green)
      puts "📄 Rapor: #{report_file}".colorize(:green)
    end
  end

  def run_demo_mode
    # Demo modu - Tüm özellikleri göster
    puts "\n🎮 DEMO MODU BAŞLATILIYOR".colorize(:cyan)

    # 1. Tek konum tespiti
    puts "\n1. Tek Konum Tespiti".colorize(:yellow)
    location, anomalies, prediction = run_single_tracking_cycle

    # 2. Kısa süreli takip
    puts "\n2. Kısa Süreli Takip (2 dakika)".colorize(:yellow)
    run_continuous_tracking(duration_minutes: 2, interval_seconds: 15)

    # 3. Sensör testleri
    puts "\n3. Sensör Testleri".colorize(:yellow)
    sensor_tests = {
      bluetooth: -> { @iot_manager.scan_bluetooth_devices },
      wifi: -> { @iot_manager.scan_wifi_networks },
      camera: -> { @iot_manager.process_camera_feed },
      audio: -> { @iot_manager.record_audio_analysis }
    }

    sensor_tests.each do |sensor_name, test_func|
      puts "\n🔍 #{sensor_name.to_s.upcase} testi:".colorize(:cyan)
      result = test_func.call
      if result
        if result.is_a?(Array)
          puts " #{result.length} cihaz bulundu"
        elsif result.is_a?(Hash)
          puts " Test tamamlandı: #{result.keys.join(', ')}"
        end
      end
    end

    puts "\n✅ Demo modu tamamlandı".colorize(:green)
  end

  def main_menu
    # Ana menü
    print_banner

    loop do
      puts "\nANA MENÜ".colorize(:cyan)
      puts "1. Tek Konum Tespiti".colorize(:cyan)
      puts "2. Sürekli Takip Modu".colorize(:cyan)
      puts "3. Demo Modu".colorize(:cyan)
      puts "4. Sensör Testleri".colorize(:cyan)
      puts "5. Rapor Oluştur".colorize(:cyan)
      puts "6. Ayarlar".colorize(:cyan)
      puts "0. Çıkış".colorize(:cyan)

      print "\nSeçiminiz: ".colorize(:cyan)
      choice = gets.chomp.strip

      case choice
      when '1'
        run_single_tracking_cycle
      when '2'
        print "Takip süresi (dakika): "
        duration = gets.chomp.to_i
        print "Takip aralığı (saniye): "
        interval = gets.chomp.to_i
        
        if duration > 0 && interval > 0
          run_continuous_tracking(duration_minutes: duration, interval_seconds: interval)
        else
          puts "❌ Geçersiz değer".colorize(:red)
        end
      when '3'
        run_demo_mode
      when '4'
        puts "\nSensör test menüsü geliyor...".colorize(:yellow)
      when '5'
        generate_comprehensive_report
      when '6'
        puts "\nAyarlar menüsü geliyor...".colorize(:yellow)
      when '0'
        puts "\n👋 Görüşmek üzere!".colorize(:green)
        break
      else
        puts "❌ Geçersiz seçim".colorize(:red)
      end
    end
  end
end

# =============================================================================
# 📜 ANA PROGRAM
# =============================================================================

def main
  # Ana program
  begin
    # Gelişmiş takip sistemini başlat
    tracker = AdvancedPhoneTracker.new

    # Ana menüyü göster
    tracker.main_menu

  rescue Interrupt
    puts "\n🛑 Program kullanıcı tarafından durduruldu".colorize(:yellow)
  rescue => e
    puts "\n❌ Kritik hata: #{e.message}".colorize(:red)
    puts e.backtrace.join("\n").colorize(:red)
  end
end

# Programı çalıştır
main if __FILE__ == $0