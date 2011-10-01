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

# Create a collection of test-snapshots.
#
# @param [ Array ] snapshots An array of hashes describing the snapshots to
#   create.
#
# @return [ Array<Sherlock::Models::Snapshot> ] A list of all snapshots
#   created.
def create_snapshots(snapshots)

  snapshot_models = []
  snapshots.each_with_index do |snapshot_definition, index|

    node_id = snapshot_definition[:node_id] || 'test'
    timestamp = snapshot_definition[:timestamp] || Time.now - index.minutes
    path = snapshot_definition[:path] || 'test.metric'
    counter = snapshot_definition[:counter] || 1

    # Create the snapshot.
    snapshot_model = Sherlock::Models::Snapshot.create!(:node_id => node_id, :timestamp => timestamp)

    # Create the metric.
    metric = Sherlock::Models::Metric.create!(:snapshot => snapshot_model, :node_id => node_id, :timestamp => timestamp, :path => path, :counter => counter)

    snapshot_models << snapshot_model

  end

  snapshot_models

end
