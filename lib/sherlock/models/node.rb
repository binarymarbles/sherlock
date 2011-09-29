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

module Sherlock #:nodoc
  module Models #:nodoc

    # Defines a node registered in the node configuration file.
    class Node

      include ActiveModel::Validations

      attr_accessor :attributes
      attr_accessor :id, :hostname, :client, :provider

      # Validate that the node have a id set.
      validates :id, :presence => true

      # Validate that the node have a hostname set.
      validates :hostname, :presence => true

      # Validate that the node have a client set.
      validates :client, :presence => true

      # Validate that the node have a provider set.
      validates :provider, :presence => true

      # Initialize a new node.
      #
      # @example Initialize a new node
      #   new Node(:id => 'test-node')
      def initialize(attributes = {})
        attributes.each do |name, value|
          send(:"#{name}=", value)
        end
      end

      # Setter for the client. This looks up the client from the client
      # configuration and uses the Client model as the value for the client
      # attribute.
      #
      # @param [ String ] client_id The ID of the client.
      #
      # @raise [ Sherlock::Errors::ConfigError ] If the client is not found in
      #   the client configuration.
      def client=(client_id)

        @client = client_id.blank? ? nil : Sherlock::Config.client_by_id(client_id)
        if @client.blank? && !client_id.blank?
          raise Sherlock::Errors::ConfigError.new('nodes.json', "Unable to find client #{client_id}")
        end

        @client

      end

      # Setter for the provider. This looks up the provider from the provider
      # configuration and uses the Provider model as the value for the
      # provider attribute.
      #
      # @param [ String ] provider_id The ID of the provider.
      #
      # @raise [ Sherlock::Errors::ConfigError ] If the provider is not found
      #   in the client configuration.
      def provider=(provider_id)

        @provider = provider_id.blank? ? nil : Sherlock::Config.provider_by_id(provider_id)
        if @provider.blank? && !provider_id.blank?
          raise Sherlock::Errors::ConfigError.new('nodes.json', "Unable to find provider #{provider_id}")
        end

        @provider

      end
      
    end

  end
end
