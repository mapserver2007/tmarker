#!/usr/bin/ruby

$: << File.dirname(__FILE__) + '/../'

require 'service/mail'

mail = Tmarker::Service::Mail.new
mail.send({
  :to => 'ryuichissr@hotmail.com',
  :subject => '超電磁砲最高！',
  :message => 'test\ntest'
})

#require "rubygems"
#require "tlsmail"
#require "time"
#
#str = 'test'
#
#Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
#Net::SMTP.start("smtp.gmail.com", "587", "localhost", "mapserver2007@gmail.com", "paranoia", :plain) { |smtp|
#  smtp.send_message str, "mapserver2007@gmail.com", "ryuichissr@hotmail.com"
#}


