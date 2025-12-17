### 📄 src/utils/logger.rb

# frozen_string_literal: true

require 'logger'
require 'fileutils'
require 'colorize'

module Utils
  class CustomLogger
    # Özel logger sınıfı
    
    attr_reader :logger
    
    def initialize(log_file = 'logs/tracking.log', level = Logger::INFO)
      @log_dir = File.dirname(log_file)
      FileUtils.mkdir_p(@log_dir)
      
      @logger = Logger.new(log_file, 10, 1024000) # 10 files, 1MB each
      @logger.level = level
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity.ljust(5)} | #{progname} | #{msg}\n"
      end
    end

    def self.instance
      @instance ||= new
    end

    def info(message, progname = 'TRACKER')
      @logger.info(progname) { message }
      puts message.colorize(:green) if Settings::LOG_LEVEL == :debug
    end

    def warn(message, progname = 'TRACKER')
      @logger.warn(progname) { message }
      puts message.colorize(:yellow) if [:debug, :info, :warn].include?(Settings::LOG_LEVEL)
    end

    def error(message, progname = 'TRACKER')
      @logger.error(progname) { message }
      puts message.colorize(:red)
    end

    def debug(message, progname = 'TRACKER')
      @logger.debug(progname) { message }
      puts message.colorize(:cyan) if Settings::LOG_LEVEL == :debug
    end

    def fatal(message, progname = 'TRACKER')
      @logger.fatal(progname) { message }
      puts message.colorize(:red).on_white
    end
  end
end

# Global logger metodları
def log_info(message, progname = 'TRACKER')
  Utils::CustomLogger.instance.info(message, progname)
end

def log_warn(message, progname = 'TRACKER')
  Utils::CustomLogger.instance.warn(message, progname)
end

def log_error(message, progname = 'TRACKER')
  Utils::CustomLogger.instance.error(message, progname)
end

def log_debug(message, progname = 'TRACKER')
  Utils::CustomLogger.instance.debug(message, progname)
end

def log_fatal(message, progname = 'TRACKER')
  Utils::CustomLogger.instance.fatal(message, progname)
end