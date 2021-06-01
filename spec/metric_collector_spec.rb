# encoding: utf-8

require 'spec_helper'

describe Sherlock::MetricCollector do

  context '#retrieving metrics' do
    it 'should limit metrics to the requested node' do
      create_snapshots([ { :node_id => 'test' }, { :node_id => 'test2' } ])
      collector = Sherlock::MetricCollector.new('test', ['test.metric'])
      collector.metrics.keys.size.should == 1
      collector.metrics['test.metric'].size.should == 1
    end

    it 'should limit metrics to the requested paths' do
      create_snapshots([ { :path => 'test.metric.1' }, { :path => 'test.metric.2' }])
      collector = Sherlock::MetricCollector.new('test', ['test.metric.1'])
      collector.metrics.keys.size.should == 1
      collector.metrics['test.metric.1'].size.should == 1
    end
    
    it 'should limit metrics to the requested paths with wildcards' do
      create_snapshots([ { :path => 'test.metric.1' }, { :path => 'test.metric.2' }, { :path => 'test.other_metric.1' } ])
      collector = Sherlock::MetricCollector.new('test', ['test.*.1'])
      collector.metrics.keys.size.should == 2
      collector.metrics['test.metric.1'].size.should == 1
      collector.metrics['test.other_metric.1'].size.should == 1
    end

    it 'should limit metrics to the requested time span' do
      create_snapshots([ { :timestamp => Time.now - 2.days }, { :timestamp => Time.now } ])
      collector = Sherlock::MetricCollector.new('test', ['test.metric'], :from => Time.now - 1.hour)
      collector.metrics.keys.size.should == 1
      collector.metrics['test.metric'].size.should == 1
    end

    it 'should return values as-is for counter type' do
      create_snapshots([ { :counter => 1 }, { :counter => 2 }, { :counter => 3 }, { :counter => 4 } ])
      puts "All metrics: #{Sherlock::Models::Metric.all.inspect}"
      collector = Sherlock::MetricCollector.new('test', ['test.metric'])
      collector.metrics.keys.size.should == 1
      collector.metrics['test.metric'].size.should == 4
      collector.metrics['test.metric'][0].counter.should == 1
      collector.metrics['test.metric'][1].counter.should == 2
      collector.metrics['test.metric'][2].counter.should == 3
      collector.metrics['test.metric'][3].counter.should == 4
    end

    it 'should return incremental values for incremental type' do
      create_snapshots([ { :counter => 10 }, { :counter => 12 }, { :counter => 20 }, { :counter => 22 } ])
      collector = Sherlock::MetricCollector.new('test', ['test.metric'], :type => 'incremental')
      collector.metrics.keys.size.should == 1
      collector.metrics['test.metric'].size.should == 4
      collector.metrics['test.metric'][0].counter.should == 0
      collector.metrics['test.metric'][1].counter.should == 2
      collector.metrics['test.metric'][2].counter.should == 8
      collector.metrics['test.metric'][3].counter.should == 2
    end

    it 'should reset the counter with incremental type' do
      create_snapshots([ { :counter => 10 }, { :counter => 12 }, { :counter => 2 }, { :counter => 22 } ])
      collector = Sherlock::MetricCollector.new('test', ['test.metric'], :type => 'incremental')
      collector.metrics.keys.size.should == 1
      collector.metrics['test.metric'].size.should == 4
      collector.metrics['test.metric'][0].counter.should == 0
      collector.metrics['test.metric'][1].counter.should == 2
      collector.metrics['test.metric'][2].counter.should == 2
      collector.metrics['test.metric'][3].counter.should == 20
    end
  end

end
