
### 📄 src/config/settings.rb
# frozen_string_literal: true

module Settings
  # Genel ayarlar
  DEVICE_PREFIX = "RUBY_DEVICE"
  DEFAULT_TRACKING_INTERVAL = 30 # seconds
  DEFAULT_DURATION = 60 # minutes
  
  # Veritabanı ayarları
  DATABASE_PATH = "data/tracking.db"
  DATABASE_TIMEOUT = 5000 # ms
  
  # Rapor ayarları
  REPORT_OUTPUT_DIR = "reports"
  REPORT_FORMATS = %w[html png json].freeze
  
  # Sensör ayarları
  GPS_PORTS = ['/dev/ttyUSB0', '/dev/ttyAMA0', 'COM3', 'COM4'].freeze
  WIFI_SCAN_TIMEOUT = 10 # seconds
  BLUETOOTH_SCAN_TIMEOUT = 15 # seconds
  CAMERA_INDEX = 0
  AUDIO_DURATION = 3 # seconds
  AUDIO_SAMPLE_RATE = 44100
  
  # AI/ML ayarları
  ANOMALY_CONTAMINATION = 0.1
  PREDICTION_CONFIDENCE_THRESHOLD = 0.3
  BEHAVIOR_ANALYSIS_WINDOW = 10 # data points
  
  # Blockchain ayarları
  DIFFICULTY_LEVEL = 4 # zeros required for proof
  BLOCKCHAIN_PERSISTENCE = true
  
  # Güvenlik ayarları
  ENCRYPTION_KEY_ROTATION = false
  MAX_ANOMALY_SEVERITY = 1.0
  
  # Görselleştirme ayarları
  CHART_WIDTH = 800
  CHART_HEIGHT = 600
  MAP_ZOOM_LEVEL = 12
  
  # Log ayarları
  LOG_LEVEL = :info # :debug, :info, :warn, :error
  LOG_FILE = "logs/tracking.log"
  LOG_MAX_SIZE = 10 * 1024 * 1024 # 10MB
  LOG_MAX_FILES = 5
  
  # Performans ayarları
  MAX_SENSOR_THREADS = 4
  DATA_RETENTION_DAYS = 30
  CLEANUP_INTERVAL = 3600 # seconds
  
  # Coğrafi sınırlar (İstanbul bölgesi)
  DEFAULT_REGION = {
    min_lat: 40.8,
    max_lat: 41.2,
    min_lng: 28.5,
    max_lng: 29.5
  }.freeze
end