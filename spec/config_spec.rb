# encoding: utf-8

require 'spec_helper'

describe Sherlock::Config do

  before(:each) { stub_config_directory }

  # TODO - The configs need better testing, especially the code validationg
  # the configuration file content.

  context '#loading configurations' do
    it 'should load all configuration files' do
      lambda { Sherlock::Config.configs }.should_not raise_error
    end
  end

end
