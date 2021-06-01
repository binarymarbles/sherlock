# encoding: utf-8

module Sherlock #:nodoc
  module Models #:nodoc

    # Defines a client registered in the client configuration file.
    class Client

      include ActiveModel::Validations

      attr_accessor :attributes
      attr_accessor :id, :name, :contacts

      # Validate that clients have an ID attribute set.
      validates :id, :presence => true

      # Validate that clients have a name set.
      validates :name, :presence => true

      # Validate that clients have a list of contacts defined.
      validates :contacts, :presence => true

      # Initialize a new client.
      #
      # @example Initialize a new client
      #   new Client(:id => 'test-client')
      def initialize(attributes = {})
        attributes.each do |name, value|
          send(:"#{name}=", value)
        end
        self.contacts ||= []
      end

    end

  end
end
