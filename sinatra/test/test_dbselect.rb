#!/usr/bin/ruby

$: << File.dirname(__FILE__) + '/../'

require 'models/common/db'

db = Tmarker::Common::DB.new(:groups)
ds = db.select([
  'product_group => ?', 'Book'
])



#
#ds = db.select

if !ds.nil?
  ds.each do |e|
    p e[:product_group]
  end
end
