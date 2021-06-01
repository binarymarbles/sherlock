# encoding: utf-8

module Sherlock #:nodoc
  module Models #:nodoc

    # Defines a contact for a client registered in the client configuration
    # file.
    class Contact

      include ActiveModel::Validations

      attr_accessor :attributes
      attr_accessor :name, :email

      # Validate that contacts have a name set.
      validates :name, :presence => true

      # Validate that contacts have an e-mail address set.
      validates :email, :presence => true

      # Initialize a new contact.
      #
      # @example Initialize a new contact
      #   new Contact(:name => 'Test Contact')
      def initialize(attributes = {})
        attributes.each do |name, value|
          send(:"#{name}=", value)
        end
      end

    end

  end
end
