(function() {
  var NodeFilter;
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
  $(document).ready(function() {
    if ($('body').hasClass('nodes-ui') && $('#client-filter').length > 0 && $('#provider-filter').length > 0) {
      return new NodeFilter();
    }
  });
}).call(this);
