# encoding: utf-8

# Copyright 2011 Binary Marbles.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rubygems'
require 'bundler/setup'

# Set up the development environment.
Bundler.require(:development)
ENV['RACK_ENV'] = 'test'

# Add the Sherlock lib directory to the load path.
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '../lib'))
require 'sherlock'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'support', '**', '*.rb'))].each do |f|
  require f
end

# Configure RSpec.
RSpec.configure do |config|

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
    %w(Snapshot Process Label Metric MetricAvg5m MetricAvg1h MetricAvg1d MetricAvg1w).each do |model_class_name|
      model_class = Sherlock::Models.const_get(model_class_name)
      model_class.delete_all
    end
  end
  
end
