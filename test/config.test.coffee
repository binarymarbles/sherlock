configModule = require '../lib/config'
configModule.setConfigDirectory './test/config'

module.exports =
  'load valid config files': (test) ->
    test.doesNotThrow ->
      configModule.load()
    test.done()

  'load client configurations': (test) ->
    config = configModule.load()
    test.equals config.clients.length, 2

    test.equals config.clients[0].id, 'test-client-1'
    test.equals config.clients[0].name, 'Test Client 1'
    test.equals config.clients[0].contacts.length, 1
    test.equals config.clients[0].contacts[0].name, 'Test Client 1 Contact 1'
    test.equals config.clients[0].contacts[0].email, 'testcontact1@testclient1.tld'

    test.equals config.clients[1].id, 'test-client-2'
    test.equals config.clients[1].name, 'Test Client 2'
    test.equals config.clients[1].contacts.length, 2
    test.equals config.clients[1].contacts[0].name, 'Test Client 2 Contact 1'
    test.equals config.clients[1].contacts[0].email, 'testcontact1@testclient2.tld'
    test.equals config.clients[1].contacts[1].name, 'Test Client 2 Contact 2'
    test.equals config.clients[1].contacts[1].email, 'testcontact2@testclient2.tld'

    test.done()

  'load provider configurations': (test) ->
    config = configModule.load()
    test.equals config.providers.length, 2

    test.equals config.providers[0].id, 'test-provider-1'
    test.equals config.providers[0].name, 'Test Provider 1'

    test.equals config.providers[1].id, 'test-provider-2'
    test.equals config.providers[1].name, 'Test Provider 2'

    test.done()

  'load node configurations': (test) ->
    config = configModule.load()
    test.equals config.nodes.length, 2

    test.equals config.nodes[0].id, 'test1'
    test.equals config.nodes[0].hostname, 'test1.fqdn'
    test.equals config.nodes[0].ip_address, '10.0.0.1'
    test.equals config.nodes[0].client.id, 'test-client-1'
    test.equals config.nodes[0].client.name, 'Test Client 1'
    test.equals config.nodes[0].provider.id, 'test-provider-1'
    test.equals config.nodes[0].provider.name, 'Test Provider 1'

    test.equals config.nodes[1].id, 'test2'
    test.equals config.nodes[1].hostname, 'test2.fqdn'
    test.equals config.nodes[1].ip_address, '10.0.0.2'
    test.equals config.nodes[1].client.id, 'test-client-2'
    test.equals config.nodes[1].client.name, 'Test Client 2'
    test.equals config.nodes[1].provider.id, 'test-provider-2'
    test.equals config.nodes[1].provider.name, 'Test Provider 2'

    test.done()

  'load graph configurations': (test) ->
    config = configModule.load()
    test.equals config.graphs.length, 2

    test.equals config.graphs[0].id, 'network_traffic'
    test.equals config.graphs[0].name, 'Network Traffic'
    test.equals config.graphs[0].type, 'incremental'
    test.equals config.graphs[0].keys.length, 2
    test.equals config.graphs[0].keys[0], 'network_interfaces.*.bytes.rx'
    test.equals config.graphs[0].keys[1], 'network_interfaces.*.bytes.tx'

    test.equals config.graphs[1].id, 'load_average'
    test.equals config.graphs[1].name, 'Load Average'
    test.equals config.graphs[1].type, 'counter'
    test.equals config.graphs[1].keys.length, 1
    test.equals config.graphs[1].keys[0], 'load.average'

    test.done()
