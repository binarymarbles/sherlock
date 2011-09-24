#!/usr/bin/env ruby
require 'rubygems'
require 'net/http'
require 'uri'

json_data = File.open('config/agent-data-test.json', 'r') { |f| f.read }

url = URI.parse('http://localhost:6750/watson/snapshot')
http = Net::HTTP.new(url.host, url.port)
request = Net::HTTP::Post.new(url.path)
request.body = json_data
request['Content-Type'] = 'application/json'
response = http.request(request)

puts "Posted data to Sherlock with status code #{response.code}:"
puts response.body
