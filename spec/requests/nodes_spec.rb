# encoding: utf-8

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
