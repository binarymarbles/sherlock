# Adds support for filtering nodes by client and/or provider.
class NodeFilter

  # Initializer. Adds callbacks to the filtering selectors.
  constructor: ->
    @clientSelector = $('#client-filter')
    @providerSelector = $('#provider-filter')

    @clientSelector.change =>
      @reloadNodeList()
        
    @providerSelector.change =>
      @reloadNodeList()

  # Reload the node list
  reloadNodeList: (params) ->
    client = @selectedClient()
    provider = @selectedProvider()
    
    location = "/nodes?client=#{client}&provider=#{provider}"
    document.location.href = location

  # Returns the client currently selected in the client filter dropdown.
  selectedClient: ->
    @clientSelector.val()

  # Returns the provider currently selected in the provider filter dropdown.
  selectedProvider: ->
    @providerSelector.val()

# Loads graphs into graph containers.
class GraphViewer

  # Initialize the graph viewer.
  constructor: (container) ->
    @container = $(container)
    @containerId = @container.attr('id')
    @nodeId = @container.attr('data-node-id')
    @graphId = @container.attr('data-graph-id')
    @loadGraph()

  # Load graph metrics and display the graph within the container.
  loadGraph: ->
    $.get "/nodes/#{@nodeId}/metrics/#{@graphId}", (data) =>
      @renderGraph data

  # Render a graph with the data passed in as an argument.
  renderGraph: (data) ->

    # Build the series for the chart.
    chartSeries = []
    for path, metrics of data.metrics
      chartSeries.push
        name: path
        lineWidth: 1
        marker:
          radius: 1
        data: metrics

    chart = new Highcharts.Chart
      chart:
        renderTo: @containerId
        type: 'line'

      title:
        text: "#{data.graph.name} for #{data.node.hostname}"

      xAxis:
        type: 'datetime'

      yAxis:
        title:
          text: data.graph.unit
        min: 0

      series: chartSeries

$(document).ready ->

  # Enable the node filter if the client and provider fields are available.
  if $('body').hasClass('nodes-ui') && $('#client-filter').length > 0 && $('#provider-filter').length > 0
    new NodeFilter()

  # Load the graph if we have a container for it.
  graphContainers = $('.graph[data-graph-id][data-node-id][id]')
  graphContainers.each ->
    new GraphViewer(@)
