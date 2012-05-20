require 'rubygems'
require 'tlsmail'
require 'time'
require 'yaml'
require 'kconv'
require 'models/common/util'
require 'models/common/log'

module Tmarker
  module Common
    class Mail

      include Tmarker::Common::Util

      def initialize
        @logger = Tmarker::Common::Log.instance
        @config = YAML.load_file(config_path)["mail"]
        @gmail_host = 'smtp.gmail.com'
        @gmail_port = 587
      end

      def send(header)
        if (valid_header?(header))
          # Send mail
          Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
          Net::SMTP.start(@gmail_host,  @gmail_port, "localhost",
            @config["address"], @config["password"], "plain") do |smtp|
              smtp.send_message header[:message].tojis, @config["address"], header[:to]
          end
        end
      end

      private

      def valid_header?(header)
        send_ok = true

        # "mailto" not found case
        unless (header[:to])
          @logger.write("NOT FOUND MAIL TO.", "error")
          send_ok = false
        end

        # "message" not found case
        unless (header[:message])
          @logger.write("NOT FOUND MAIL MESSAGE.", "error")
          send_ok = false
        end

        send_ok
      end
    end
  end
end