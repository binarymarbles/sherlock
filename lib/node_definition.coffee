# Defines a node read from the node configuration file.
class NodeDefinition

  constructor: (config, json) ->
    throw "Missing ID for node #{json}" unless json.id?
    @id = json.id

    throw "Missing hostname for node #{json}" unless json.hostname?
    @hostname = json.hostname

    throw "Missing ip address for node #{json}" unless json.ip_address?
    @ip_address = json.ip_address

    throw "Missing client for node #{json}" unless json.client?
    throw "Invalid client for node #{json}" unless config.clientById(json.client)?
    @client = config.clientById json.client

    throw "Missing provider for node #{json}" unless json.provider?
    throw "Invalid provider for node #{json}" unless config.providerById(json.provider)?
    @provider = config.providerById json.provider

module.exports = NodeDefinition
