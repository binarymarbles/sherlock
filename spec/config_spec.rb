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
