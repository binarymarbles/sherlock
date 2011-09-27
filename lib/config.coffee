_ = require 'underscore'
fs = require 'fs'
 
ClientDefinition = require './client_definition'
ProviderDefinition = require './provider_definition'
NodeDefinition = require './node_definition'
GraphDefinition = require './graph_definition'

# Holds the configuration after it's loaded from the configuration files.
config = null

# Holds the path to the configuration directory where the configuration files
# are found.
configDirectory = __dirname + '/../config'

# The application configuration class. This holds configuration information
# about all the data registered in the configuration files.
class Config

  constructor: (configDirectory) ->
    @configDirectory = configDirectory
    @readClientConfig()
    @readProviderConfig()
    @readNodeConfig()
    @readGraphConfig()

  # Returns the client matching the specified ID.
  clientById: (id) ->
    _.first _.select @clients, (client) =>
      client.id == id

  # Returns the provider matching the specified ID.
  providerById: (id) ->
    _.first _.select @providers, (provider) =>
      provider.id == id

  # Returns the node matching the specified ID.
  nodeById: (id) ->
    _.first _.select @nodes, (node) =>
      node.id == id

  # Returns the node matching the specified hostname.
  nodeByHostname: (hostname) ->
    _.first _.select @nodes, (node) =>
      node.hostname == hostname

  # Returns the graph matching the specified ID.
  graphById: (id) ->
    _.first _.select @graphs, (graph) =>
      graph.id == id

  # Returns the path to the specified configuration file.
  configFilePath: (filename) ->
    "#{@configDirectory}/#{filename}.json"

  # Read a configuration file and pass on each element in the JSON data
  # structure to the specified callback function.
  readConfig: (filename, callback) ->

    data = fs.readFileSync @configFilePath(filename), 'utf-8'
    json = JSON.parse(data)

    for jsonElement in json
      callback(jsonElement)

  # Read the client configuration file.
  readClientConfig: ->
    @clients = []

    @readConfig 'clients', (clientJson) =>
      @clients.push new ClientDefinition clientJson

  # Read the provider configuration file.
  readProviderConfig: ->
    @providers = []

    @readConfig 'providers', (providerJson) =>
      @providers.push new ProviderDefinition providerJson

  # Read the node configuration file.
  readNodeConfig: ->
    @nodes = []

    @readConfig 'nodes',  (nodeJson) =>
      @nodes.push new NodeDefinition @, nodeJson

  # Read the graph configuration file.
  readGraphConfig: ->
    @graphs = []

    @readConfig 'graphs', (graphJson) =>
      @graphs.push new GraphDefinition graphJson

module.exports =
  setConfigDirectory: (path) ->
    configDirectory = path

  load: ->
    if !config?
      config = new Config(configDirectory)
      
    config
