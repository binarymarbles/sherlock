_ = require 'underscore'

# Defines a graph read from the graph configuration file.
class GraphDefinition

  constructor: (json) ->
    throw "Missing ID for graph #{json}" unless json.id?
    @id = json.id

    throw "Missing name for graph #{json}" unless json.name?
    @name = json.name

    throw "Missing type for graph #{json}" unless json.type?
    throw "Invalid type for graph #{json}" unless _.include ['counter', 'differential'], json.type
    @type = json.type

    throw "Missing keys for graph #{json}" unless json.keys?
    throw "Invalid keys for graph #{json}" unless _.isArray(json.keys) && json.keys.length > 0
    @keys = json.keys

module.exports = GraphDefinition
