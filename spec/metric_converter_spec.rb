# encoding: utf-8

# Copyright 2011 Binary Marbles.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
