require 'rubygems'
require 'active_support'
require 'socket'
require 'uri'

module Tmarker
  module Common
    module Util
      def url_for_rails
        "http://tmarker.summer-lights.jp/"
      end

      def url_for_sinatra
        "http://i.tmarker.summer-lights.jp/"
      end

      def root_path
        File::expand_path(File.dirname(__FILE__) + '/../../')
      end

      def config_path
        root_path + '/config/tmarker.yml'
      end

      def message_path
        root_path + '/config/message.yml'
      end

      def error_log_path
        root_path + '/log/error/'
      end

      def access_log_path
        root_path + '/log/access/'
      end

      def fixed_date(date)
        unless date.nil?
          t = date.split(/-/)
          year, month, day = t[0], t[1], t[2]
          data = Time.local(year, month, day).beginning_of_month
        end
        data
      end

      def allow_function
        ['item', 'wish']
      end

      def jancode?(code)
        !(/\d{13}/ =~ code).nil?
      end

      def asin?(code)
        !(/^B[A-Z0-9]{9}/ =~ code).nil?
      end

      def iphone?(useragent)
        !!(/iPhone/ =~ useragent)
      end

      def valid_func?(func)
        !!allow_function.index(func)
      end

      def url2hostname(url)
        uri = URI.parse(url)
        Socket.gethostbyname(uri.host)[0] rescue nil
      end
    end
  end
end