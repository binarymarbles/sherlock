# encoding: utf-8

require 'json'

class Sherlock::Controllers::Nodes < Sherlock::Sinatra::BaseController

  get '/' do
    title('Nodes')
    expose(:clients, Sherlock::Config.clients)
    expose(:current_client, params[:client])
    expose(:providers, Sherlock::Config.providers)
    expose(:current_provider, params[:provider])
    expose(:nodes, Sherlock::Config.nodes_with_filter(:client => params[:client],:provider => params[:provider]))
    render_template :index
  end

  get '/:node_id' do

    node = Sherlock::Config.node_by_id(params[:node_id])
    graph_id = params[:graph] || Sherlock::Config.graphs.first.id
    graph = Sherlock::Config.graph_by_id(graph_id)
    state = Sherlock::NodeState.new(params[:node_id])
    
    title(node.hostname)
    expose(:node, node)
    expose(:graphs, Sherlock::Config.graphs)
    expose(:current_graph, params[:graph])
    expose(:graph, graph)
    expose(:state, state)
    render_template :show

  end

  get '/:node_id/metrics/:graph_id' do

    node = Sherlock::Config.node_by_id(params[:node_id])
    graph = Sherlock::Config.graph_by_id(params[:graph_id])
    
    # Collect metrics for the graph.
    collector = Sherlock::MetricCollector.new(params[:node_id], graph.paths, :conversion => graph.conversion)
    metrics = collector.metrics

    # Convert the metrics to JSON.
    json = {
      :graph => {
        :name => graph.name,
        :unit => graph.unit
      },
      :node => {
        :hostname => node.hostname
      },
      :metrics => {}
    }
    metrics.each do |path, data|
      json[:metrics][path] ||= []
      data.each do |metric|
        json[:metrics][path] << [metric.timestamp.to_i, metric.counter]
      end
    end

    # Render the JSON.
    content_type 'application/json'
    json.to_json

  end

end
