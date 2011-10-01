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

module Sherlock #:nodoc
  module Models #:nodoc
  end
end

# "Dummy" models.
require 'sherlock/models/metric_data'

# ActiveModel-models.
require 'sherlock/models/client'
require 'sherlock/models/contact'
require 'sherlock/models/provider'
require 'sherlock/models/graph'
require 'sherlock/models/graph_key'
require 'sherlock/models/node'

# MongoMapper models.
require 'sherlock/models/process'
require 'sherlock/models/label'
require 'sherlock/models/metric'
require 'sherlock/models/current_metric'
require 'sherlock/models/metric_avg_5m'
require 'sherlock/models/metric_avg_1h'
require 'sherlock/models/metric_avg_1d'
require 'sherlock/models/metric_avg_1w'
require 'sherlock/models/snapshot'
