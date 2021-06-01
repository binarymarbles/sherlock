# encoding: utf-8

module Sherlock #:nodoc

  # Returns the current application environment.
  #
  # @return [ String ] Current environment name.
  def self.env
    ENV['RACK_ENV'] || 'development'
  end

  # Returns a logger for the current application instance.
  #
  # @return [ Sherlock::Logger ] Current application instance logger.
  def self.log
    @logger ||= Sherlock::Logger.new
  end

end

# Require some external dependencies.
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'active_model'
require 'mongo_mapper'

# Configure MongoMapper with our database configuration.
database_config = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml'))
config = HashWithIndifferentAccess.new(YAML.load(File.read(database_config))[Sherlock.env])

MongoMapper.connection = Mongo::Connection.new(config[:hostname], 27017, :pool_size => 5, :pool_timeout => 5)
MongoMapper.database = config[:database]

# Require the Sherlock libraries.
require 'sherlock/logger'
require 'sherlock/errors'
require 'sherlock/extensions'
require 'sherlock/models'
require 'sherlock/config'
require 'sherlock/snapshot_parser'
require 'sherlock/metric_collector'
require 'sherlock/metric_converter'
require 'sherlock/node_state'
