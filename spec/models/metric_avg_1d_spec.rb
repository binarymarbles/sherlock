# encoding: utf-8

require 'spec_helper'

describe Sherlock::Models::MetricAvg1d do
  context '#validations' do
    let(:metric_avg) { Sherlock::Models::MetricAvg1d.new(:node_id => 'test_node', :timestamp => Time.now, :path => 'test.metric') }

    it 'should be valid' do
      metric_avg.should be_valid
    end

    it 'should validate presence of node_id' do
      metric_avg.node_id = nil
      metric_avg.should_not be_valid
    end

    it 'should validate presence of timestamp' do
      metric_avg.timestamp = nil
      metric_avg.should_not be_valid
    end
    
    it 'should validate presence of path' do
      metric_avg.path = nil
      metric_avg.should_not be_valid
    end
  end
end
