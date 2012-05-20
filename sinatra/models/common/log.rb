require 'logger'
require 'yaml'
require 'time'
require 'fileutils'
require 'singleton'
require 'models/common/util'

module Tmarker
  module Common
    class Log

      include Singleton
      include Tmarker::Common::Util

      def initialize
        @path = File.exist?(error_log_path) && File.exist?(access_log_path)
      end

      def write(content, level)
        if (@path)
          # Write logfile
          case level
          when "fatal"
            logger = Logger.new(logfile(error_log_path))
            logger.level = Logger::FATAL
            logger.fatal(content)
          when "error"
            logger = Logger.new(logfile(error_log_path))
            logger.level = Logger::ERROR
            logger.error(content)
          when "warn"
            logger = Logger.new(logfile(error_log_path))
            logger.level = Logger::WARN
            logger.warn(content)
          when "info"
            logger = Logger.new(logfile(access_log_path))
            logger.level = Logger::INFO
            logger.info(content)
          when "debug"
            logger = Logger.new(logfile(error_log_path))
            logger.level = Logger::DEBUG
            logger.debug(content)
          end
        end
      end

      private

      def logfile(path)
        t = Time.now
        File.join(path, "#{t.strftime("%Y%m%d")}.log")
      end
    end
  end
end