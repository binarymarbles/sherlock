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
