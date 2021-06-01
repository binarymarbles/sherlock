# encoding: utf-8

# Create a collection of test-snapshots.
#
# @param [ Array ] snapshots An array of hashes describing the snapshots to
#   create.
#
# @return [ Array<Sherlock::Models::Snapshot> ] A list of all snapshots
#   created.
def create_snapshots(snapshots)

  snapshot_models = []
  time_offset = snapshots.size
  snapshots.each do |snapshot_definition|

    node_id = snapshot_definition[:node_id] || 'test'
    timestamp = snapshot_definition[:timestamp] || Time.now - time_offset.minutes
    path = snapshot_definition[:path] || 'test.metric'
    counter = snapshot_definition[:counter] || 1

    # Create the snapshot.
    snapshot_model = Sherlock::Models::Snapshot.create!(:node_id => node_id, :timestamp => timestamp)

    # Create the metric.
    metric = Sherlock::Models::Metric.create!(:snapshot => snapshot_model, :node_id => node_id, :timestamp => timestamp, :path => path, :counter => counter)

    time_offset -= 1
    snapshot_models << snapshot_model

  end

  snapshot_models

end
