# encoding: utf-8

require 'spec_helper'

describe Sherlock::Controllers::Dashboard do

  let(:app) { Sherlock::Controllers::Dashboard }

  context 'GET "/"', :type => :request do
    it 'should be successful' do
      get('/')
      last_response.should be_ok
      last_response.body.should have_content('Dashboard goes here')
    end
  end

end
