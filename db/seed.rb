# Reset all collections in the database.
%w(Snapshot Process Label Metric MetricAvg5m MetricAvg1h MetricAvg1d MetricAvg1w).each do |model_class_name|
  model_class = Sherlock::Models.const_get(model_class_name)
  model_class.delete_all
end

# Create a random amount of processes for a snapshot.
def create_processes_for_snapshot(snapshot)
  [1 .. rand(10)+10].each do
    Sherlock::Models::Process.create!(
      :snapshot => snapshot,
      :timestamp => snapshot.timestamp,
      :user => %w(nobody root httpd postfix).sample,
      :pid => rand(1000) + 1000,
      :cpu_usage => rand(50),
      :memory_usage => rand(25),
      :virtual_memory_size => rand(1000) + 1000,
      :residential_set_size => rand(1000) + 1000,
      :tty => %w(? tty0 tty1 tty2).sample,
      :state => %w(S Ss Z R+).sample,
      :started_at => (Time.now - (rand(100) + 1).minutes).strftime('%H:%M'),
      :cpu_time => (Time.now - (rand(100) + 1).minutes).strftime('%H:%M'),
      :command => %w(syslogd ntpd autofsd httpd cupsd).sample
    )
  end
end

# Create a set of metrics for a snapshot.
def create_metrics_for_snapshot(snapshot)

  @eth0_rx_counter ||= 0
  @eth0_tx_counter ||= 0
  
  # Build a random value for the network counters.
  @eth0_rx_counter += rand(100000)
  @eth0_tx_counter += rand(200000)

  # Create the load.average metric.
  Sherlock::Models::Metric.create!(
    :node_id => snapshot.node_id,
    :timestamp => snapshot.timestamp,
    :path => 'load.average',
    :counter => rand()
  )

  # Create the eth0 network metrics.
  Sherlock::Models::Metric.create!(
    :node_id => snapshot.node_id,
    :timestamp => snapshot.timestamp,
    :path => 'network_interfaces.eth0.bytes.rx',
    :counter => @eth0_rx_counter
  )
  Sherlock::Models::Metric.create!(
    :node_id => snapshot.node_id,
    :timestamp => snapshot.timestamp,
    :path => 'network_interfaces.eth0.bytes.tx',
    :counter => @eth0_tx_counter
  )

end

# Create 2 days worth of snapshots.
time = Time.now - 2.days
while time < Time.now do

  if time.hour == 0 && time.min == 0
    puts "Creating snapshots for #{time}"
  end

  snapshot = Sherlock::Models::Snapshot.create!(:node_id => 'test', :timestamp => time)
  create_processes_for_snapshot(snapshot)
  create_metrics_for_snapshot(snapshot)

  time = time + 1.minute

end
