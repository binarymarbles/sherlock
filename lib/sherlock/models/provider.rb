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
