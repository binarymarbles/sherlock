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

describe Sherlock::Models::Snapshot do
  context '#attributes' do
    let(:snapshot) { Sherlock::Models::Snapshot.new }

    it 'should have many processes' do
      snapshot.should respond_to(:processes)
      snapshot.should respond_to(:processes=)
    end

    it 'should have many metrics' do
      snapshot.should respond_to(:metrics)
      snapshot.should respond_to(:metrics=)
    end
  end
end
