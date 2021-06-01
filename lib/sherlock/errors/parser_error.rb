# encoding: utf-8

module Sherlock #:nodoc
  module Errors #:nodoc

    # This error is raised when an error occurs while parsing data delivered
    # to Sherlock from an agent.
    #
    # @example Create a parser error.
    #   ParserError.new('Error description')
    class ParserError < BaseError
    end

  end
end
