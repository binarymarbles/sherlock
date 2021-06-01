# encoding: utf-8

module Sherlock #:nodoc
  module Errors #:nodoc

    # This is the base class for all errors raised by Sherlock.
    class BaseError < StandardError
    end

  end
end

require 'sherlock/errors/parser_error'
require 'sherlock/errors/config_error'
