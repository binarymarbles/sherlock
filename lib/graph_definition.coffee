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
    throw "Invalid keys for graph #{json}" unless typeof(json.keys) == 'object' && _.keys(json.keys).length > 0
    @keys = json.keys

  # Return the appropriate label for the given metric path.
  labelForPath: (path) ->

    # If we have a direct match with one of the graph keys, use the value of
    # that key.
    if @keys[path]?
      return @keys[path]

    # If we didn't havea direct match, go through each key and see if any of
    # the wildcard keys matches.
    for keyPath, keyLabel of @keys
      if keyPath.indexOf('*') > -1

        quotedPath = keyPath.replace '.', '\\.'
        quotedPath = quotedPath.replace '*', '(.*?)'
        regexp = new RegExp("^#{quotedPath}$")
        matches = path.match regexp
        if matches? && matches.length > 0
          replaceRegexp = new RegExp(/\$(\d+)/)
          while replaceMatch = replaceRegexp.exec keyLabel
            keyLabel = keyLabel.replace replaceMatch[0], matches[parseInt(replaceMatch[1])]
          return keyLabel

    # Return the path as-is if we can't find a label.
    path

module.exports = GraphDefinition
