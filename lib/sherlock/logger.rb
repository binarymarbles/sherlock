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
