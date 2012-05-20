require 'services/notice'
require 'models/common/util'
require 'models/common/log'

module Tmarker
  module Service
    module Item

      include Tmarker::Common::Util

      def initialize(params = nil)
        @logger = Tmarker::Common::Log.instance
        @notice = Tmarker::Notice.instance
        @message = YAML.load_file(message_path)
        @db = Tmarker::Common::DB.new(:groups)
      end

      protected

      def get_item(jancode)
      end

      def unget_item(jancode)
        empty_item = {}
        @notice.message << (@message["E000001"] % jancode)
        empty_item
      end

      def get_elem(item)
      end

    end
  end
end