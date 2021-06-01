
module Sherlock #:nodoc

  # Gathers state information for a node.
  class NodeState

    attr_reader :uptime, :load_average, :memory_usage, :swap_usage, :process_count

    # Initialize a new node state.
    #
    # @param [ String ] node_id The ID of the node to load state for.
    def initialize(node_id)
      @node_id = node_id
      load_state
    end

    private

    # Load the state for the current node
    def load_state

      # Set default state values.
      set_default_state

      # Load current state metrics for this node.
      paths = [
        'uptime', 'load.average', 'memory.physical.used', 'memory.swap.used',
        'processes.count'
      ]
      query = Sherlock::Models::CurrentMetric.where(:node_id => @node_id)
      query = query.where(:$or => paths.collect { |p| {:path => p} })
      metrics = query.all

      # Go through the queries and change the defaults for each matching
      # metric found.
      metrics.each do |metric|
        case metric.path
        when 'uptime'
          @uptime = metric.counter
        when 'load.average'
          @load_average = metric.counter
        when 'memory.physical.used'
          @memory_usage = metric.counter
        when 'memory.swap.used'
          @swap_usage = metric.counter
        when 'processes.count'
          @process_count = metric.counter
        end
      end

    end

    # Set default state values.
    def set_default_state
      @uptime = @load_average = @memory_usage = @swap_usage = @process_count = 0
    end

  end

end
