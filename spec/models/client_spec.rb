# encoding: utf-8

require 'spec_helper'

describe Sherlock::Models::Client do

  context '#validations' do
    let(:client) { Sherlock::Models::Client.new(:id => 'test', :name => 'Test Client', :contacts => ['test']) }

    it 'should be valid' do
      client.should be_valid
    end

    it 'should validate presence of id' do
      client.id = nil
      client.should_not be_valid
    end

    it 'should validate presence of name' do
      client.name = nil
      client.should_not be_valid
    end

    it 'should not allow a blank list of contacts' do
      client.contacts = []
      client.should_not be_valid
    end
  end

end
