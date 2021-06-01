# encoding: utf-8

require 'log4r'

module Sherlock #:nodoc

  # Provides Sherlock with logging facilities via Log4r.
  class Logger

    def initialize

      # Log to a environment-specific files under config/ in the application
      # root.
      filename = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'logs', "#{Sherlock.env}.log"))
      @logger = Log4r::Logger.new('sherlock')

      format = Log4r::PatternFormatter.new(:pattern => "%d\t %l\t %m", :date_pattern => '%b %d %H:%M:%S')
      @logger.outputters << Log4r::FileOutputter.new('file', :filename => filename, :trunc => false, :formatter => format)

    end

    # Log a message with debug level.
    #
    # @param [ String ] message The message to log.
    def debug(*args)
      log(:debug, *args)
    end

    # Log a message with info level.
    #
    # @param [ String ] message The message to log.
    def info(*args)
      log(:info, *args)
    end

    # Log a message with warn level.
    #
    # @param [ String ] message The message to log.
    def warn(*args)
      log(:warn *args)
    end

    # Log a message with error level.
    #
    # @param [ String ] message The message to log.
    def error(*args)
      log(:error, *args)
    end

    # Log a message with fatal level.
    #
    # @param [ String ] message The message to log.
    def fatal(*args)
      log(:fatal, *args)
    end

    private

    # Log a message with the specified log level to the current log output.
    def log(level, *args)
      texts = args.collect(&:to_s)
      @logger.send(level, texts.join(' '))
    end
    
  end

end
