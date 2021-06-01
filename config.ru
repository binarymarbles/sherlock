# encoding: utf-8
# vim:ft=ruby

require File.expand_path(File.join(File.dirname(__FILE__), 'app'))

run Rack::URLMap.new({
  '/' => Sherlock::Controllers::Dashboard,
  '/nodes' => Sherlock::Controllers::Nodes,
  '/watson' => Sherlock::Controllers::Watson
})
