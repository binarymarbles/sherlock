# encoding: utf-8

require 'spec_helper'

describe Sherlock::Models::Node do

  context '#validations' do
    before(:each) do
      
      # Stub out the client_by_id and provider_by_id methods in the Sherlock
      # configuration.
      Sherlock::Config.stub!(:client_by_id).and_return(client)
      Sherlock::Config.stub!(:provider_by_id).and_return(provider)

    end

    let(:client) { Sherlock::Models::Client.new(:id => 'test', :name => 'Test Client', :contacts => ['test']) }
    let(:provider) { Sherlock::Models::Provider.new(:id => 'test-provider', :name => 'Test Provider') }
    let(:node) { Sherlock::Models::Node.new(:id => 'test-node', :hostname => 'test-node.tld', :client => 'test-client', :provider => 'test-provider') }

    it 'should be valid' do
      node.should be_valid
    end

    it 'should validate presence of id' do
      node.id = nil
      node.should_not be_valid
    end

    it 'should validate presence of hostname' do
      node.hostname = nil
      node.should_not be_valid
    end

    it 'should validate presence of client' do
      node.client = nil
      node.should_not be_valid
    end

    it 'should validate presence of provider' do
      node.provider = nil
      node.should_not be_valid
    end
  end

end
