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

module Sherlock

  # Returns the current application environment.
  #
  # @return [ String ] Current environment name.
  def self.env
    ENV['RACK_ENV']
  end

end

# Require some external dependencies.
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'active_model'

# Require the Sherlock libraries.
require 'sherlock/errors'
require 'sherlock/models'
require 'sherlock/config'
require 'sherlock/snapshot_parser'