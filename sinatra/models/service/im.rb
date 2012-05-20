require 'rubygems'
require 'net/http'
require 'digest/sha1'
require 'json'
require 'models/common/log'

module Tmarker
  module Service
    class IM

      HOST = 'im.kayac.com'
      PATH = '/api/post/'

      def initialize(params = {})
        @logger = Tmarker::Common::Log.instance
        @username = params[:username]
        @password = params[:password]
        @sig = params[:sig]
      end

      def notify(message = nil)
        result = false
        path = PATH
        data = []
        response = nil

        begin
          unless @username.nil? || message.nil?
            path += @username
          else
            raise ArgumentError
          end
        rescue => e
          @logger.write(e, "error")
          return result
        end

        if !@sig.nil?
          data << 'sig=%s' % Digest::SHA1.hexdigest(message + @sig)
        elsif !@password.nil?
          data << 'password=%s' % @password
        end

        data << 'message=%s' % message
        data = data.join('&')

        header = {
          'Host' => HOST,
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Content-Length' => data.size.to_s
        }

        Net::HTTP.version_1_2
        Net::HTTP.start(HOST, 80) do |http|
          response = http.post(path, data, header)
        end

        json = JSON.parse(response.body)

        if json["result"] == "posted"
          result = true
        else
          @logger.write(json["error"], "error")
        end

        result

      end
    end
  end
end