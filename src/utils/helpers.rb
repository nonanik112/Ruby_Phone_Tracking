# frozen_string_literal: true

require 'json'
require 'time'
require 'securerandom'

module Utils
  module Helpers
    # Yardımcı metodlar
    
    def self.format_time(timestamp)
      Time.at(timestamp).strftime('%Y-%m-%d %H:%M:%S')
    end

    def self.format_duration(seconds)
      hours = seconds / 3600
      minutes = (seconds % 3600) / 60
      secs = seconds % 60
      
      if hours > 0
        "#{hours}h #{minutes}m #{secs}s"
      elsif minutes > 0
        "#{minutes}m #{secs}s"
      else
        "#{secs}s"
      end
    end

    def self.format_distance(km)
      if km < 1
        "#{(km * 1000).round(0)}m"
      elsif km < 10
        "#{km.round(1)}km"
      else
        "#{km.round(0)}km"
      end
    end

    def self.format_speed(kmh)
      "#{kmh.round(1)} km/h"
    end

    def self.generate_device_id(prefix = Settings::DEVICE_PREFIX)
      "#{prefix}_#{Time.now.to_i}_#{SecureRandom.hex(4)}"
    end

    def self.safe_parse_json(json_string, default = {})
      JSON.parse(json_string, symbolize_names: true)
    rescue JSON::ParserError
      default
    end

    def self.calculate_bounding_box(locations)
      return nil if locations.empty?

      lats = locations.map { |loc| loc[:lat] }
      lngs = locations.map { |loc| loc[:lng] }

      {
        min_lat: lats.min,
        max_lat: lats.max,
        min_lng: lngs.min,
        max_lng: lngs.max,
        center_lat: (lats.min + lats.max) / 2,
        center_lng: (lngs.min + lngs.max) / 2
      }
    end

    def self.is_within_region?(lat, lng, region = Settings::DEFAULT_REGION)
      lat >= region[:min_lat] && lat <= region[:max_lat] &&
      lng >= region[:min_lng] && lng <= region[:max_lng]
    end

    def self.calculate_accuracy(confidence)
      # Güven skorundan accuracy hesapla
      return 100.0 if confidence.nil? || confidence <= 0
      [100.0 / confidence, 1000.0].min
    end

    def self.normalize_rssi(rssi)
      # RSSI değerini normalize et (-100 ile -30 arası)
      return 0.0 if rssi.nil?
      normalized = (rssi + 100) / 70.0
      [0.0, normalized, 1.0].sort[1]
    end

    def self.estimate_distance_from_rssi(rssi, tx_power = -59)
      # RSSI'dan mesafe tahmini (basit path loss modeli)
      return 1.0 if rssi.nil?
      
      ratio = (tx_power - rssi) / 20.0
      distance = 10 ** ratio
      [1.0, distance, 100.0].sort[1]
    end

    def self.calculate_travel_time(distance, speed)
      return 0 if distance.nil? || speed.nil? || speed <= 0
      (distance / speed) * 3600 # saniye cinsinden
    end

    def self.is_reasonable_movement?(from_lat, from_lng, to_lat, to_lng, time_diff)
      return true if time_diff.nil? || time_diff <= 0
      
      distance = Geocoder::Calculations.distance_between(
        [from_lat, from_lng],
        [to_lat, to_lng]
      )
      
      speed = distance / (time_diff / 3600.0) # km/h
      speed <= 300 # Maksimum 300 km/h makul kabul edilir
    end

    def self.generate_mock_location(center_lat: 41.0082, center_lng: 28.9784, radius: 0.01)
      # Merkez etrafında rastgele konum üret
      angle = rand(0..(2 * Math::PI))
      r = rand(0..radius)
      
      lat_offset = r * Math.cos(angle)
      lng_offset = r * Math.sin(angle) / Math.cos(center_lat * Math::PI / 180)
      
      {
        lat: center_lat + lat_offset,
        lng: center_lng + lng_offset,
        accuracy: rand(10..200),
        confidence: rand(0.3..0.9)
      }
    end

    def self.compress_data(data)
      # Veri sıkıştırma (basit JSON minify)
      JSON.generate(data).delete(' ')
    end

    def self.decompress_data(compressed)
      # Veri çözme
      JSON.parse(compressed, symbolize_names: true)
    rescue
      nil
    end

    def self.format_file_size(bytes)
      units = %w[B KB MB GB TB]
      unit_index = 0
      
      while bytes >= 1024 && unit_index < units.length - 1
        bytes /= 1024.0
        unit_index += 1
      end
      
      "#{bytes.round(1)}#{units[unit_index]}"
    end

    def self.sanitize_filename(filename)
      # Dosya adını güvenli hale getir
      filename.gsub(/[^a-zA-Z0-9._-]/, '_').gsub(/_+/, '_')
    end

    def self.generate_timestamp
      Time.now.strftime('%Y%m%d_%H%M%S')
    end

    def self.parse_nmea_coordinates(lat_str, lat_dir, lng_str, lng_dir)
      # NMEA koordinatlarını parse et
      return nil unless lat_str && lat_dir && lng_str && lng_dir
      
      lat = parse_nmea_coord(lat_str, lat_dir)
      lng = parse_nmea_coord(lng_str, lng_dir)
      
      return nil unless lat && lng
      
      { lat: lat, lng: lng }
    end

    def self.parse_nmea_coord(coord_str, direction)
      return nil unless coord_str && direction
      
      # DDMM.MMMM formatını parse et
      coord = coord_str.to_f
      degrees = (coord / 100).floor
      minutes = coord % 100
      
      decimal = degrees + minutes / 60.0
      
      # Yön uygula
      decimal *= -1 if direction =~ /[SW]/
      
      decimal
    end
  end
end
