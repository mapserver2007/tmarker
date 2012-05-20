require 'socket'
require 'uri'
require 'ping'

class Access < ActiveRecord::Base
  validates_presence_of  :user_id, :allow_id, :allow_url
  validates_presence_of  :allow_host, :allow_ipaddr
  validates_format_of    :allow_url, :with => /^http?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+\$,%#]+/
  validates_inclusion_of :allow_id, :in => 1..3
  before_validation :create_allowed_host, :create_allowed_ipaddr

  attr_accessible :user_id, :allow_id, :allow_url

  def create_allowed_host
    begin
      uri = URI.parse(allow_url)
      if uri.scheme == "http"
        @hostent = Socket.gethostbyname(uri.host)
        self.allow_host = @hostent[0] if host_exist?(@hostent[0])
      end
    rescue
      nil
    end
  end

  def create_allowed_ipaddr
    unless @hostent.nil?
      self.allow_ipaddr = @hostent[3].unpack("C4").join(".")
    end
  end

  private

  def host_exist?(hostname)
    Ping.pingecho(hostname, 3, "http")
  end
end
