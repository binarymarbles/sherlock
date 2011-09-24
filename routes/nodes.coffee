MetricCollector = require '../lib/metric_collector'
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
    collector = new MetricCollector req.node, req.graph
    collector.metrics (error, dataSet) ->
      if error?
        throw new Error(error.message)
      else
        res.render 'graphs/show',
          node: req.node
          graph: req.graph
          metrics: dataSet
