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

require 'json'

module Sherlock #:nodoc

  # Stores the global application configuration for Sherlock. This includes:
  #  - Client definitions.
  #  - Location definitions.
  #  - Graph definitions.
  #  - Node configurations.
  module Config

    extend self

    # Returns a hash containing all the different configuration objects.
    #
    # @return [ Hash ] A hash containing each of the configuration objects.
    #
    # @raise [ Sherlock::Errors::ConfigError ] If loading or parsing a
    #   configuration file failed.
    def configs
      {
        :clients => clients,
        :providers => providers,
        :graphs => graphs,
        :nodes => nodes
      }
    end

    # Returns an array containing the client configuration.
    #
    # @return [ Array ] An array containing the client configuration.
    #
    # @raise [ Sherlock::Errors::ConfigError ] If loading or parsing the
    #   client configuration file failed.
    def clients
      @clients ||= load_client_configuration
    end
    
    # Returns an array containing the provider configuration.
    #
    # @return [ Array ] An array containing the provider configuration.
    #
    # @raise [ Sherlock::Errors::ConfigError ] If loading or parsing the
    #   provider configuration file failed.
    def providers
      @providers ||= load_provider_configuration
    end
    
    # Returns an array containing the graph configuration.
    #
    # @return [ Array ] An array containing the graph configuration.
    #
    # @raise [ Sherlock::Errors::ConfigError ] If loading or parsing the
    #   graph configuration file failed.
    def graphs
      @graphs ||= load_graph_configuration
    end

    # Returns an array containing the node configuration.
    #
    # @return [ Array ] An array containing the node configuration.
    #
    # @raise [ Sherlock::Errors::ConfigError ] If loading or parsing the
    #   node configuration file failed.
    def nodes
      @nodes ||= load_node_configuration
    end

    # Returns a client with the specified ID.
    #
    # @param [ String ] id The ID of the client to locate.
    #
    # @return [ Sherlock::Models::Client ] The client with the specified ID,
    #   or nil if the client was not found.
    def client_by_id(id)
      clients.select { |client| client.id == id }.first
    end
    
    # Returns a provider with the specified ID.
    #
    # @param [ String ] id The ID of the provider to locate.
    #
    # @return [ Sherlock::Models::Provider ] The provider with the specified
    #   ID, or nil if the provider was not found.
    def provider_by_id(id)
      providers.select { |provider| provider.id == id }.first
    end
    
    # Returns a graph with the specified ID.
    #
    # @param [ String ] id The ID of the graph to locate.
    #
    # @return [ Sherlock::Models::Graph ] The graph with the specified ID, or
    #   nil if the graph was not found.
    def graph_by_id(id)
      graphs.select { |graph| graph.id == id }.first
    end
    
    # Returns a node with the specified ID.
    #
    # @param [ String ] id The ID of the node to locate.
    #
    # @return [ Sherlock::Models::Node ] The node with the specified ID, or
    #   nil if the node was not found.
    def node_by_id(id)
      nodes.select { |node| node.id == id }.first
    end

    # Returns the node list filtered by the optional list of arguments.
    #
    # @param [ Hash ] options The list of options to filter the node list by.
    #
    # @return [ Array<Sherlock::Models::Node> ] The list of nodes after
    #   applying any filters.
    def nodes_with_filter(options)
      nodes.reject do |node|
        (!options[:client].blank? && node.client.id != options[:client]) || (!options[:provider].blank? && node.provider.id != options[:provider])
      end
    end
    
    private

    # Return the directory where the configuration files are found. By default
    # this is the config/ directory under the application root directory.
    #
    # @return [ String ] The full path to the configuration directory.
    def config_directory
      File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config'))
    end

    # Return the path to the specified configuration file.
    #
    # @param [ String ] filename The relative path to the configuration file.
    #
    # @return [ String ] The full path to the configuration file.
    def config_file_path(filename)
      File.join(config_directory, filename)
    end

    # Raise a config error.
    #
    # @param [ String ] filename The config filename where the error originated from.
    # @param [ String ] message The message to use when raising the error.
    #
    # @raise [ Sherlock::Errors::ConfigError ] The requested config error.
    def raise_config_error(filename, message)
      raise Errors::ConfigError.new(filename, message)
    end
    
    # Load a JSON configuration file from the configuration directory.
    #
    # @return [ Hash ] A hash containing the data from the configuration file.
    #
    # @raise [ Sherlock::Errors::ConfigError ] If loading the configuration
    #   file failed.
    def load_json_config(filename)
      begin
        JSON.parse(File.read(config_file_path(filename)), :symbolize_names => true)
      rescue StandardError => e
        raise_config_error(filename, "Unable to load configuration file: #{e.message}")
      end
    end

    # Load the client configuration from the configuration directory.
    #
    # @return [ Hash ] The configuration file data.
    #
    # @raise [ Sherlock::Errors::ConfigError ] If the configuration file
    #   failed to load, or if there was an error in the file.
    def load_client_configuration
      
      config_file = 'clients.json'
      config = load_json_config(config_file)

      raise_config_error(config_file, 'No clients found in configuration file') unless config.is_a?(Array) && config.size > 0

      clients = []

      # Build a client model for each of the clients in the configuration.
      config.each do |client_info|

        contact_infos = client_info.delete(:contacts)

        client = Models::Client.new(client_info)

        # Validate the contact array for the client.
        raise_config_error(config_file, "Missing contact list for client #{client.id}") if contact_infos.blank? || !contact_infos.is_a?(Array) || contact_infos.size == 0

        # Add the contacts to the client.
        contact_infos.each do |contact_info|

          contact = Models::Contact.new(contact_info)
          unless contact.valid?
            raise_config_error(config_file, "Invalid contact found for client #{client.id} in configuration file: #{contact.errors.inspect}")
          end

          client.contacts << contact

        end

        unless client.valid?
          raise_config_error(config_file, "Invalid client found in configuration file: #{client.errors.inspect}")
        end

        clients << client

      end

      clients
      
    end

    # Load the provider configuration from the configuration directory.
    #
    # @return [ Hash ] The configuration file data.
    #
    # @raise [ Sherlock::Errors::ConfigError ] If the configuration file
    #   failed to load, or if there was an error in the file.
    def load_provider_configuration
      
      config_file = 'providers.json'
      config = load_json_config(config_file)

      raise_config_error(config_file, 'No providers found in configuration file') unless config.is_a?(Array) && config.size > 0

      providers = []

      # Build a provider model for each of the providers in the configuration.
      config.each do |provider_info|

        provider = Models::Provider.new(provider_info)
        unless provider.valid?
          raise_config_error(config_file, "Invalid provider found in configuration file: #{provider.errors.inspect}")
        end

        providers << provider

      end

      providers
      
    end

    # Load the graph configuration from the configuration directory.
    #
    # @return [ Hash ] The configuration file data.
    #
    # @raise [ Sherlock::Errors::ConfigError ] If the configuration file
    #   failed to load, or if there was an error in the file.
    def load_graph_configuration
      
      config_file = 'graphs.json'
      config = load_json_config(config_file)

      raise_config_error(config_file, 'No graphs found in configuration file') unless config.is_a?(Array) && config.size > 0

      graphs = []

      # Build a graph model for each of the graphs in the configuration.
      config.each do |graph_info|

        key_infos = graph_info.delete(:keys)
        graph = Models::Graph.new(graph_info)

        # Validate the keys hash for the graph.
        raise_config_error(config_file, "Missing key list for graph #{graph.id}") if key_infos.blank? || !key_infos.is_a?(Hash) || key_infos.keys.size == 0

        # Add the keys to the graph.
        key_infos.each do |metric, label|

          key = Models::GraphKey.new(:metric => metric, :label => label)
          unless key.valid?
            raise_config_error(config_file, "Invalid key found for graph #{graph.id} in configuration file: #{key.errors.inspect}")
          end

          graph.keys << key

        end

        unless graph.valid?
          raise_config_error(config_file, "Invalid graph found in configuration file: #{graph.errors.inspect}")
        end

        graphs << graph

      end

      graphs
      
    end

    # Load the node configuration from the configuration directory.
    #
    # @return [ Hash ] The configuration file data.
    #
    # @raise [ Sherlock::Errors::ConfigError ] If the configuration file
    #   failed to load, or if there was an error in the file.
    def load_node_configuration
      
      config_file = 'nodes.json'
      config = load_json_config(config_file)

      raise_config_error(config_file, 'No nodes found in configuration file') unless config.is_a?(Array) && config.size > 0

      nodes = []

      # Build a node model for each of the nodes in the configuration.
      config.each do |node_info|

        node = Models::Node.new(node_info)
        unless node.valid?
          raise_config_error(config_file, "Invalid node found in configuration file: #{node.errors.inspect}")
        end

        nodes << node

      end

      nodes
      
    end

  end

end
