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

  # let(:app) { Sherlock::Controllers::Nodes }

  before(:each) do
    stub_config_directory
    Capybara.app = Sherlock::Controllers::Nodes.new
  end

  context 'GET "/"', :type => :request do
    it 'should contain a list of nodes' do
      visit '/'
      page.should have_link('test')
      page.should have_content('test.fqdn')
      page.should have_link('Test Client 1')
      page.should have_link('Test Provider 1')
      page.should have_link('test2')
      page.should have_content('test2.fqdn')
      page.should have_link('Test Client 2')
      page.should have_link('Test Provider 2')
    end

    it 'should filter nodes by client' do
      visit '/?client=test-client'
      page.should_not have_link('Test Client 2')
    end

    it 'should filter nodes by provider' do
      visit '/?provider=test-provider'
      page.should_not have_link('Test Provider 2')
    end
  end

  context 'GET "/node_id"', :type => :request do
    it 'should display the node page' do
      visit '/test'
      page.should have_content('test.fqdn')
      page.should have_content('Open alerts')
      page.should have_content('Uptime')
      page.should have_content('Memory usage')
      page.should have_content('Swap usage')
      page.should have_content('Load average')
      page.should have_content('Process count')
    end
  end

end
