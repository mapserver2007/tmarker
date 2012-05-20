require 'singleton'

module Tmarker
  class Notice

    include Singleton

    attr_accessor :message

    def initialize
      @message = []
    end

    def finalizer
      initialize
    end

  end
end