# encoding: utf-8

# Copyright 2011 Binary Marbles.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    
    title(node.hostname)
    expose(:node, node)
    expose(:graphs, Sherlock::Config.graphs)
    expose(:current_graph, params[:graph])
    expose(:graph, graph)
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
