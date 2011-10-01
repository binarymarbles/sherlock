(function() {
  var GraphViewer, NodeFilter;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  NodeFilter = (function() {
    function NodeFilter() {
      this.clientSelector = $('#client-filter');
      this.providerSelector = $('#provider-filter');
      this.clientSelector.change(__bind(function() {
        return this.reloadNodeList();
      }, this));
      this.providerSelector.change(__bind(function() {
        return this.reloadNodeList();
      }, this));
    }
    NodeFilter.prototype.reloadNodeList = function(params) {
      var client, location, provider;
      client = this.selectedClient();
      provider = this.selectedProvider();
      location = "/nodes?client=" + client + "&provider=" + provider;
      return document.location.href = location;
    };
    NodeFilter.prototype.selectedClient = function() {
      return this.clientSelector.val();
    };
    NodeFilter.prototype.selectedProvider = function() {
      return this.providerSelector.val();
    };
    return NodeFilter;
  })();
  GraphViewer = (function() {
    function GraphViewer(container) {
      this.container = $(container);
      this.containerId = this.container.attr('id');
      this.nodeId = this.container.attr('data-node-id');
      this.graphId = this.container.attr('data-graph-id');
      this.loadGraph();
    }
    GraphViewer.prototype.loadGraph = function() {
      return $.get("/nodes/" + this.nodeId + "/metrics/" + this.graphId, __bind(function(data) {
        return this.renderGraph(data);
      }, this));
    };
    GraphViewer.prototype.renderGraph = function(data) {
      var chart, chartSeries, metrics, path, _ref;
      chartSeries = [];
      _ref = data.metrics;
      for (path in _ref) {
        metrics = _ref[path];
        chartSeries.push({
          name: path,
          lineWidth: 1,
          marker: {
            radius: 1
          },
          data: metrics
        });
      }
      return chart = new Highcharts.Chart({
        chart: {
          renderTo: this.containerId,
          type: 'line'
        },
        title: {
          text: "" + data.graph.name + " for " + data.node.hostname
        },
        xAxis: {
          type: 'datetime'
        },
        yAxis: {
          title: {
            text: data.graph.unit
          },
          min: 0
        },
        series: chartSeries
      });
    };
    return GraphViewer;
  })();
  $(document).ready(function() {
    var graphContainers;
    if ($('body').hasClass('nodes-ui') && $('#client-filter').length > 0 && $('#provider-filter').length > 0) {
      new NodeFilter();
    }
    graphContainers = $('.graph[data-graph-id][data-node-id][id]');
    return graphContainers.each(function() {
      return new GraphViewer(this);
    });
  });
}).call(this);
