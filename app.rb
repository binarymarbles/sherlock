# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/content_for'
require 'haml'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'sherlock'
require 'sherlock/sinatra'

# Require all Sinatra controllers.
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'app', 'controllers', '*.rb'))].each do |f|
  require f
end
