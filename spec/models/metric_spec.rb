# encoding: utf-8

require 'spec_helper'

describe Sherlock::Models::Metric do
  context '#attributes' do
    let(:metric) { Sherlock::Models::Metric.new }

    it 'should belong to snapshot' do
      metric.should respond_to(:snapshot)
      metric.should respond_to(:snapshot=)
    end
  end
  
  context '#validations' do
    let(:metric) { Sherlock::Models::Metric.new(:node_id => 'test_node', :timestamp => Time.now, :path => 'test.metric', :counter => 10.0) }

    it 'should be valid' do
      metric.should be_valid
    end

    it 'should validate presence of node_id' do
      metric.node_id = nil
      metric.should_not be_valid
    end

    it 'should validate presence of timestamp' do
      metric.timestamp = nil
      metric.should_not be_valid
    end
    
    it 'should validate presence of path' do
      metric.path = nil
      metric.should_not be_valid
    end

    it 'should validate presence of counter' do
      metric.counter = nil
      metric.should_not be_valid
    end
  end

  context '#averages' do
    # let(:create_second_metric) do
    #   p = Sherlock::SnapshotParser.new(valid_json)
    #   p.persist!
    # end

    let(:snapshot) { Sherlock::Models::Snapshot.create!(:node_id => 'test', :timestamp => Time.now) }
    let(:metric_time) { Time.local(2011, 9, 29, 18, 11) }

    let(:create_metric) do
      Sherlock::Models::Metric.create!(:snapshot => snapshot, :node_id => 'test', :timestamp => Time.now, :path => 'test.metric', :counter => 100)
    end

    let(:create_second_metric) do
      Sherlock::Models::Metric.create!(:snapshot => snapshot, :node_id => 'test', :timestamp => Time.now, :path => 'test.metric', :counter => 100)
    end

    before(:each) do

      # Freeze Time.now at a specific time.
      Timecop.freeze(metric_time)

      # Create the base metric.
      create_metric

    end

    # Release the frozen time.
    after(:each) { Timecop.return }
    
    it 'should persist 5 minute averages' do
      Sherlock::Models::MetricAvg5m.count.should == 1
    end

    it 'should persist 1 hour averages' do
      Sherlock::Models::MetricAvg1h.count.should == 1
    end

    it 'should persist 1 day averages' do
      Sherlock::Models::MetricAvg1d.count.should == 1
    end

    it 'should persist 1 week averages' do
      Sherlock::Models::MetricAvg1w.count.should == 1
    end

    context '#5 minute averages' do
      it 'should only have one set per 5 minutes' do
        Timecop.freeze(metric_time + 1.minute) do
          create_second_metric
          Sherlock::Models::MetricAvg5m.count.should == 1
        end
      end
      
      it 'should create a new set of averages after 5 minutes' do
        Timecop.freeze(metric_time + 5.minutes) do
          create_second_metric
          Sherlock::Models::MetricAvg5m.count.should == 2
        end
      end
    end

    context '#1 hour averages' do
      it 'should only have one set per hour' do
        Timecop.freeze(metric_time + 40.minutes) do
          create_second_metric
          Sherlock::Models::MetricAvg1h.count.should == 1
        end
      end
      
      it 'should create a new set of averages after one hour' do
        Timecop.freeze(metric_time + 1.hour) do
          create_second_metric
          Sherlock::Models::MetricAvg1h.count.should == 2
        end
      end
    end

    context '#1 day averages' do
      it 'should only have one set per day' do
        Timecop.freeze(metric_time + 3.hours) do
          create_second_metric
          Sherlock::Models::MetricAvg1d.count.should == 1
        end
      end

      it 'should create a new set of averages after one day' do
        Timecop.freeze(metric_time + 1.day) do
          create_second_metric
          Sherlock::Models::MetricAvg1d.count.should == 2
        end
      end
    end

    context '#1 week averages' do
      it 'should only have one set per week' do
        Timecop.freeze(metric_time + 2.days) do
          create_second_metric
          Sherlock::Models::MetricAvg1w.count.should == 1
        end
      end

      it 'should create a new set of averages after one week' do
        Timecop.freeze(metric_time + 1.week) do
          create_second_metric
          Sherlock::Models::MetricAvg1w.count.should == 2
        end
      end
    end
  end
end
