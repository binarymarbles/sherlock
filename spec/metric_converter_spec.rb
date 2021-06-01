# encoding: utf-8

require 'spec_helper'

describe Sherlock::MetricConverter do

  let(:data_set) do
    {
      'test.metric' => [
        Sherlock::Models::MetricData.new(Time.now - 1.second, 1000000),
        Sherlock::Models::MetricData.new(Time.now, 1000000)
      ]
    }
  end

  let(:converter) { Sherlock::MetricConverter.new(data_set) }

  it 'should convert bytes to Mbit per second' do
    result = converter.apply_conversion('bytes_to_mbit_per_second')
    result['test.metric'][0].counter.should == 0
    result['test.metric'][1].counter.should == 7.63
  end

  it 'should convert bytes to MB' do
    result = converter.apply_conversion('bytes_to_mb')
    result['test.metric'][0].counter.should == 0.95
    result['test.metric'][1].counter.should == 0.95
  end

end
