#!/usr/bin/ruby

$: << File.dirname(__FILE__) + '../../'

require 'models/service/im'

im = Tmarker::Service::IM.new({
  :username => 'yourname',
  :passsword => "",
  :sig => 'yoursig'
})

res = im.notify('test')

p res