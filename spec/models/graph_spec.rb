# encoding: utf-8

require 'spec_helper'

describe Sherlock::Models::Graph do

  context '#validations' do
    let(:graph) { Sherlock::Models::Graph.new(:id => 'test-graph', :name => 'Test Graph', :type => 'counter', :unit => 'test-unit', :conversion => 'bytes_to_mb', :keys => [Sherlock::Models::GraphKey.new(:metric => 'test.metric', :label => 'Test Label')]) }

    it 'should be valid' do
      graph.should be_valid
    end

    it 'should validate presence of id' do
      graph.id = nil
      graph.should_not be_valid
    end

    it 'should validate presence of name' do
      graph.name = nil
      graph.should_not be_valid
    end

    it 'should validate presence of type' do
      graph.type = nil
      graph.should_not be_valid
    end

    it 'should not allow invalid types' do
      graph.type = 'invalid'
      graph.should_not be_valid
    end

    it 'should validate presence of unit' do
      graph.unit = nil
      graph.should_not be_valid
    end

    it 'should not validate presence of conversion' do
      graph.conversion = nil
      graph.should be_valid
    end

    it 'should not allow invalid conversions' do
      graph.conversion = 'invalid'
      graph.should_not be_valid
    end

    it 'should not allow a blank list of keys' do
      graph.keys = []
      graph.should_not be_valid
    end
  end
  
end
