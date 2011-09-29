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

describe Sherlock::Models::Process do
  context '#attributes' do
    let(:process) { Sherlock::Models::Process.new }

    it 'should belong to snapshot' do
      process.should respond_to(:snapshot)
      process.should respond_to(:snapshot=)
    end
  end

  context '#validations' do
    let(:snapshot) { Sherlock::Models::Snapshot.new }
    let(:process) do
      Sherlock::Models::Process.new(
        :snapshot => snapshot,
        :timestamp => Time.now,
        :user => 'test_user',
        :pid => 1000,
        :cpu_usage => 50,
        :memory_usage => 25,
        :command => 'test_command'
      )
    end

    it 'should be valid' do
      process.should be_valid
    end

    it 'should validate presence of snapshot' do
      process.snapshot = nil
      process.should_not be_valid
    end

    it 'should validate presence of timestamp' do
      process.timestamp = nil
      process.should_not be_valid
    end

    it 'should validate presence of user' do
      process.user = nil
      process.should_not be_valid
    end

    it 'should validate presence of pid' do
      process.pid = nil
      process.should_not be_valid
    end

    it 'should validate presence of cpu usage' do
      process.cpu_usage = nil
      process.should_not be_valid
    end

    it 'should validate presence of memory usage' do
      process.memory_usage = nil
      process.should_not be_valid
    end

    it 'should validate presence of command' do
      process.command = nil
      process.should_not be_valid
    end
  end
end
