# encoding: utf-8

module Sherlock #:nodoc
  module Models #:nodoc

    # Defines a provider registered in the provider configuration file.
    class Provider

      include ActiveModel::Validations

      attr_accessor :attributes
      attr_accessor :id, :name

      # Validate that the provider has an ID set.
      validates :id, :presence => true

      # Validate that the provider has a name set.
      validates :name, :presence => true

      # Initialize a new provider.
      #
      # @example Initialize a new provider
      #   new Provider(:id => 'test-provider')
      def initialize(attributes = {})
        attributes.each do |name, value|
          send(:"#{name}=", value)
        end
      end
      
    end

  end
end
