#!/usr/bin/ruby

$: << File.dirname(__FILE__) + '../../'

require 'models/service/jansearch'

jan = Tmarker::Service::JanSearch.new
p jan.get_item('4901360278374')

