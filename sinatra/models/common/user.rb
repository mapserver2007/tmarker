require 'models/common/db'

module Tmarker
  module Common
    class User
      def initialize
        @db = Tmarker::Common::DB.new(:users)
      end

      def get_user(cond)
        ds = @db.select(cond)
        ds.each do |u| return u end if ds.count == 1
      end
    end
  end
end