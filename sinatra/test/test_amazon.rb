#!/usr/bin/ruby

$: << File.dirname(__FILE__) + '../../'

require 'models/service/amazon'

key = "yourkey"
secret = "yoursecret"

jan = Tmarker::Service::Amazon.new({:key => key, :secret => secret})
p jan.get_item('4950190991526')
