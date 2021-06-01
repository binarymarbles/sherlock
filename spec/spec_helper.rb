# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'capybara/rspec'

# Set up the development environment.
Bundler.require(:development)
ENV['RACK_ENV'] = 'test'

# Add the Sherlock lib directory to the load path.
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sherlock'

# Require the main Sherlock application file for request tests.
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'app'))

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'support', '**', '*.rb'))].each do |f|
  require f
end

# Configure RSpec.
RSpec.configure do |config|

  include Rack::Test::Methods

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Reset all MongoDB collections before each test run.
  config.before(:each) do
    %w(Snapshot Process Label Metric CurrentMetric MetricAvg5m MetricAvg1h MetricAvg1d MetricAvg1w).each do |model_class_name|
      model_class = Sherlock::Models.const_get(model_class_name)
      model_class.delete_all
    end
  end
  
end
