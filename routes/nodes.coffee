MetricCollector = require '../lib/metric_collector'
MetricNumberConverter = require '../lib/metric_number_converter'

config = (require '../lib/config').load()

module.exports = (app) ->

  # Map :node_id parameters to node ids in the configuration file.
  app.param 'node_id', (req, res, next, id) ->
    node = config.nodeById id
    if !node?
      return next new Error('Unknown node ' + id)
    req.node = node
    next()

  # Map :graph_id parameters to graph ids in the configuration file.
  app.param 'graph_id', (req, res, next, id) ->
    graph = config.graphById id
    if !graph?
      return next new Error('Unknown graph ' + id)
    req.graph = graph
    next()

  # Shows an overview over all registered nodes.
  app.get '/nodes', (req, res) ->
    res.render 'nodes/index',
      nodes: config.nodes

  # Shows a list of all available graphs for a node.
  app.get '/nodes/:node_id', (req, res) ->
    res.render 'graphs/index',
      node: req.node
      graphs: config.graphs

  # Shows a graph for a node.
  app.get '/nodes/:node_id/:graph_id', (req, res) ->
    collector = new MetricCollector req.node.id, req.graph.paths(), req.graph.type
    collector.metrics (error, dataSet) ->
      if error?
        throw new Error(error.message)
      else

        console.log dataSet

        # Prepare a set of labels for all metrics.
        labels = {}
        for path, metrics of dataSet
          labels[path] = req.graph.labelForPath(path)

        # Apply conversions to the metrics if requested.
        if req.graph.conversion? && req.graph.conversion != ''
          converter = new MetricNumberConverter dataSet
          dataSet = converter.applyConversion req.graph.conversion

        res.render 'graphs/show',
          node: req.node
          graph: req.graph
          metrics: dataSet
          labels: labels
