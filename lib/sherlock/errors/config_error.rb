# encoding: utf-8

module Sherlock #:nodoc
  module Errors #:nodoc

    # This error is raised when an error occurs while loading or parsing a
    # Sherlock configuration file.
    #
    # @example Create a config error.
    #   ConfigError.new('config_file','Error description')
    class ConfigError < BaseError

      def initialize(config_file, error_description)
        super("Error while loading config file #{config_file}: #{error_description}")
      end

    end

  end
end
