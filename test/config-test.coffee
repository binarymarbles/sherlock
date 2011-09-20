should = require 'should'

configModule = require '../lib/config'
configModule.setConfigDirectory './test/config'

module.exports =
  'load config files': ->
    config = configModule.load()
    config.clients.length.should == 2
    config.providers.length.should == 2
    config.nodes.length.should == 2

  'load client configurations': ->
    config = configModule.load()
    config.clients[0].id.should.equal 'test-client-1'
    config.clients[0].name.should.equal 'Test Client 1'
    config.clients[0].contacts.length.should.equal 1
    config.clients[0].contacts[0].name.should.equal 'Test Client 1 Contact 1'
    config.clients[0].contacts[0].email.should.equal 'testcontact1@testclient1.tld'

    config.clients[1].id.should.equal 'test-client-2'
    config.clients[1].name.should.equal 'Test Client 2'
    config.clients[1].contacts.length.should.equal 2
    config.clients[1].contacts[0].name.should.equal 'Test Client 2 Contact 1'
    config.clients[1].contacts[0].email.should.equal 'testcontact1@testclient2.tld'
    config.clients[1].contacts[1].name.should.equal 'Test Client 2 Contact 2'
    config.clients[1].contacts[1].email.should.equal 'testcontact2@testclient2.tld'

  'load provider configurations': ->
    config = configModule.load()
    config.providers[0].id.should.equal 'test-provider-1'
    config.providers[0].name.should.equal 'Test Provider 1'

    config.providers[1].id.should.equal 'test-provider-2'
    config.providers[1].name.should.equal 'Test Provider 2'

  'load node configurations': ->
    config = configModule.load()
    config.nodes[0].id.should.equal 'test1'
    config.nodes[0].hostname.should.equal 'test1.fqdn'
    config.nodes[0].ip_address.should.equal '10.0.0.1'
    config.nodes[0].client.id.should.equal 'test-client-1'
    config.nodes[0].client.name.should.equal 'Test Client 1'
    config.nodes[0].provider.id.should.equal 'test-provider-1'
    config.nodes[0].provider.name.should.equal 'Test Provider 1'

    config.nodes[1].id.should.equal 'test2'
    config.nodes[1].hostname.should.equal 'test2.fqdn'
    config.nodes[1].ip_address.should.equal '10.0.0.2'
    config.nodes[1].client.id.should.equal 'test-client-2'
    config.nodes[1].client.name.should.equal 'Test Client 2'
    config.nodes[1].provider.id.should.equal 'test-provider-2'
    config.nodes[1].provider.name.should.equal 'Test Provider 2'
