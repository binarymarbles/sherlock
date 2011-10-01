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

describe Sherlock::Models::CurrentMetric do
  it 'should write the current metric when a metric is saved' do
    Sherlock::Models::Metric.create!(:node_id => 'test', :timestamp => Time.now, :path => 'test.metric', :counter => 10)
    Sherlock::Models::CurrentMetric.count.should == 1
    Sherlock::Models::CurrentMetric.find_by_node_id_and_path('test', 'test.metric').counter.should == 10
  end

  it 'should update the current metric when a newer metric is saved' do
    Sherlock::Models::Metric.create!(:node_id => 'test', :timestamp => Time.now, :path => 'test.metric', :counter => 10)
    Sherlock::Models::Metric.create!(:node_id => 'test', :timestamp => Time.now + 1.minute, :path => 'test.metric', :counter => 20)
    Sherlock::Models::CurrentMetric.count.should == 1
    Sherlock::Models::CurrentMetric.find_by_node_id_and_path('test', 'test.metric').counter.should == 20
  end

  it 'should not update the current metric when an older metric is saved' do
    Sherlock::Models::Metric.create!(:node_id => 'test', :timestamp => Time.now, :path => 'test.metric', :counter => 10)
    Sherlock::Models::Metric.create!(:node_id => 'test', :timestamp => Time.now - 1.minute, :path => 'test.metric', :counter => 20)
    Sherlock::Models::CurrentMetric.count.should == 1
    Sherlock::Models::CurrentMetric.find_by_node_id_and_path('test', 'test.metric').counter.should == 10
  end
end
