require 'rubygems'
require 'sequel'
require 'models/common/util'
require 'models/common/log'

module Tmarker
  module Common
    class DB

      include Tmarker::Common::Util

      attr_accessor :db, :table

      def initialize(table)
        @logger = Tmarker::Common::Log.instance
        @config = YAML.load_file(config_path)["db"]
        @table = table
        dbconnect
      end

      def select(where = nil)
        ds = nil
        begin
          ds = where.nil? ? dataset : dataset.filter(where)
        rescue => e
          @logger.write(e.message, "error")
          ds = nil
        end
        ds
      end

      def insert(data = nil)
        result = false
        begin
          raise ArgumentError if data.nil?
          dataset << data
          @logger.write("[DB][INSERT] #{data}", "info")
          result = true
        rescue => e
          @logger.write(e.message, "error")
        end
        result
      end

      def update(where, data)
        result = false
        begin
          raise ArgumentError if where.nil? || data.nil?
          dataset.filter(where).update(data)
          @logger.write("[DB][UPDATE] #{data}", "info")
          result = true
        rescue => e
          @logger.write(e.message, "error")
        end
        result
      end

      def delete(where)
        result = false
        begin
          raise ArgumentError if where.nil?
          if dataset.filter(where).delete == 0
            raise "delete failure."
          else
            @logger.write("[DB][DELETE] #{where}", "info")
            result = true
          end
        rescue => e
          @logger.write(e.message, "error")
        end
        result
      end

      def multi_insert(data = nil)
        result = false
        begin
          raise ArgumentError if data.nil?
          dataset.multi_insert(data)
          @logger.write("[DB][MULTI INSERT] #{data}", "info")
          result = true
        rescue => e
          @logger.write(e.message, "error")
        end
        result
      end

      private

      def dataset
        @db[@table]
      end

      def dbconnect
        @db = Sequel.connect(
          "mysql://#{@config["user"]}:#{@config["pass"]}@#{@config["host"]}/#{@config["dbname"]}",
          {:encoding => @config["encoding"]}
        )
      end

    end
  end
end
