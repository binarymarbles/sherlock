# encoding: utf-8

require 'spec_helper'

describe Sherlock::NodeState do

  let(:state) { Sherlock::NodeState.new('test') }
  
  # Create some relevant metrics.
  before(:each) do
    Sherlock::Models::CurrentMetric.create!(:node_id => 'test', :path => 'uptime', :counter => 1000)
    Sherlock::Models::CurrentMetric.create!(:node_id => 'test', :path => 'load.average', :counter => 1.4)
    Sherlock::Models::CurrentMetric.create!(:node_id => 'test', :path => 'memory.physical.used', :counter => 70000)
    Sherlock::Models::CurrentMetric.create!(:node_id => 'test', :path => 'memory.swap.used', :counter => 22000)
    Sherlock::Models::CurrentMetric.create!(:node_id => 'test', :path => 'processes.count', :counter => 50)
  end

  it 'should add uptime to state' do
    state.uptime.should == 1000
  end

  it 'should add load average to state' do
    state.load_average.should == 1.4
  end

  it 'should add physical memory used to state' do
    state.memory_usage.should == 70000
  end

  it 'should add swap memory used to state' do
    state.swap_usage.should == 22000
  end

  it 'should add process count to state' do
    state.process_count.should == 50
  end
end
