#!/usr/bin/env ruby
require 'rubygems'
require 'net/http'
require 'uri'

json_data = File.open('config/agent-data-test.json', 'r') { |f| f.read }

res = Net::HTTP.post_form(URI.parse('http://localhost:6750/watson/snapshot'), {'payload' => json_data})

puts "Posted data to Sherlock:"
puts res.body
