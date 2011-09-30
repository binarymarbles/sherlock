# Adds support for a graph selector.
class GraphSelector

  # Initialiser. Adds callback to the graph selector.
  constructor: ->
    @graphSelector = $('#graph-type')

    @graphSelector.change =>
      @reloadNode()

  # Reload the node information page.
  reloadNode: ->
    node = @currentNodeId()
    graph = @selectedGraph()

    location = "/nodes/#{node}?graph=#{graph}"
    document.location.href = location

  # Returns the ID of the currently displayed node.
  currentNodeId: ->
    $('#node-dashboard').attr('data-node-id')

  # Returns the currently selected graph.
  selectedGraph: ->
    @graphSelector.val()

$(document).ready ->

  # Enable the graph selector if we're on the node dashboard.
  if $('#node-dashboard').length > 0
    new GraphSelector()
