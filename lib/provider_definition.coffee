# Defines a provder read from the provder configuration file.
class ProviderDefinition

  constructor: (json) ->
    throw "Missing ID for provider #{json}" unless json.id?
    @id = json.id

    throw "Missing name for provider #{json}" unless json.name?
    @name = json.name

module.exports = ProviderDefinition
