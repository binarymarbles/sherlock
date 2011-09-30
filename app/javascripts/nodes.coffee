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

$(document).ready ->

  # Enable the node filter if the client and provider fields are available.
  if $('body').hasClass('nodes-ui') && $('#client-filter').length > 0 && $('#provider-filter').length > 0
    new NodeFilter()
