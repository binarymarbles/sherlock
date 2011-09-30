(function() {
  var GraphSelector;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  GraphSelector = (function() {
    function GraphSelector() {
      this.graphSelector = $('#graph-type');
      this.graphSelector.change(__bind(function() {
        return this.reloadNode();
      }, this));
    }
    GraphSelector.prototype.reloadNode = function() {
      var graph, location, node;
      node = this.currentNodeId();
      graph = this.selectedGraph();
      location = "/nodes/" + node + "?graph=" + graph;
      return document.location.href = location;
    };
    GraphSelector.prototype.currentNodeId = function() {
      return $('#node-dashboard').attr('data-node-id');
    };
    GraphSelector.prototype.selectedGraph = function() {
      return this.graphSelector.val();
    };
    return GraphSelector;
  })();
  $(document).ready(function() {
    if ($('#node-dashboard').length > 0) {
      return new GraphSelector();
    }
  });
}).call(this);
