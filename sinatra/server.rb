#!/usr/bin/ruby

$: << File.dirname(__FILE__) + '/'

require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'controllers/main'

set :public, File.dirname(__FILE__) + '/views'

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

# register item or wish
get '/:func/:apikey/:jancode', :agent => /(.*)/ do
  controller = Tmarker::Main.new(params)
  @success   = controller.exec
  @user_name = controller.user_name
  @jancode   = controller.jancode
  @messages  = controller.message
  @items     = controller.items
  haml controller.render
end

# output blogparts
get '/blogparts/:accesskey' do
  controller = Tmarker::BlogParts.new(params, request)
  @success = controller.exec
  @html    = controller.html
  haml :blogparts
end