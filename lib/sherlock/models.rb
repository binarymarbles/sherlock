# encoding: utf-8

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
