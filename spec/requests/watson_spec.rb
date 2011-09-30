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

describe Sherlock::Controllers::Watson do

  let(:app) { Sherlock::Controllers::Watson }
  let(:valid_json) { read_asset_file('agent-data/valid.json') }
  let(:invalid_json) { read_asset_file('agent-data/invalid.json') }
  let(:validation_error_json) { read_asset_file('agent-data/empty_processes.json') }

  before(:each) do
    stub_config_directory
    header('Content-Type', 'application/json')
  end

  context 'POST "/snapshot"' do
    it 'should be successful with valid json' do
      post('/snapshot', valid_json)
      last_response.should be_ok
    end

    it 'should only return the ID of the created snapshot with valid json' do
      post('/snapshot', valid_json)
      last_response.body.should =~ /^[\da-f]+$/
    end

    it 'should return 422 error code with invalid json' do
      post('/snapshot', invalid_json)
      last_response.status.should == 422
    end

    it 'should return 422 error with json containing validation errors' do
      post('/snapshot', validation_error_json)
      last_response.status.should == 422
    end
  end

end
