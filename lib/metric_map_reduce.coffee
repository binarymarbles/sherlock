class MetricMapReduce

  # Map the metrics as-is with a 1 minute resolution.
  @rawMapFunction: ->
    emit {path: @path, timestamp: @timestamp},
      path: @path
      timestamp: @timestamp
      counter: @counter
      metric_count: 1

  # Map the metrics with 5 minute resolution.
  @fiveMinuteAverageMapFunction: ->
    timestamp = @timestamp
    minutes = (5 * Math.floor(timestamp.getMinutes() / 5))
    timestamp.setMinutes(minutes)
    timestamp.setSeconds(0)

    emit {path: @path, timestamp: timestamp},
      path: @path
      timestamp: timestamp
      counter: @counter
      metric_count: 1

  # Map the metrics with one hour resolution.
  @oneHourAverageMapFunction: ->
    timestamp = @timestamp
    timestamp.setMinutes 0
    timestamp.setSeconds 0

    emit {path: @path, timestamp: timestamp},
      path: @path
      timestamp: timestamp
      counter: @counter
      metric_count: 1

  # Map the metrics with six hour resolution.
  @sixHourAverageMapFunction: ->
    timestamp = @timestamp
    hours = (6 * Math.floor(timestamp.getHours() / 6))
    timestamp.setHours hours
    timestamp.setMinutes 0
    timestamp.setSeconds 0

    emit {path: @path, timestamp: timestamp},
      path: @path
      timestamp: timestamp
      counter: @counter
      metric_count: 1

  # Map the metrics with twelve hour resolution.
  @twelveHourAverageMapFunction: ->
    timestamp = @timestamp
    hours = (12 * Math.floor(timestamp.getHours() / 12))
    timestamp.setHours hours
    timestamp.setMinutes 0
    timestamp.setSeconds 0

    emit {path: @path, timestamp: timestamp},
      path: @path
      timestamp: timestamp
      counter: @counter
      metric_count: 1

  # Map the metrics with one day resolution.
  @oneDayAverageMapFunction: ->
    timestamp = @timestamp
    timestamp.setHours 0
    timestamp.setMinutes 0
    timestamp.setSeconds 0

    emit {path: @path, timestamp: timestamp},
      path: @path
      timestamp: timestamp
      counter: @counter
      metric_count: 1

  # Map the metrics with four day resolution.
  @fourDayAverageMapFunction: ->
    timestamp = @timestamp
    firstDayOfYear = new Date timestamp.getFullYear(), 0, 0, 0, 0, 0
    
    firstDayTime = Math.floor firstDayOfYear.valueOf() / 86400000
    timestampTime = Math.ceil timestamp.valueOf() / 86400000
    timestampDayOfYear = timestampTime - firstDayTime

    averageDayOfYear = (4 * Math.floor(timestampDayOfYear / 4))
    offset = averageDayOfYear - timestampDayOfYear

    timestamp.setDate timestamp.getDate() + offset
    timestamp.setHours 0
    timestamp.setMinutes 0
    timestamp.setSeconds 0

    emit {path: @path, timestamp: timestamp},
      path: @path
      timestamp: timestamp
      counter: @counter
      metric_count: 1

  # Map the metrics with one week resolution.
  @oneWeekAverageMapFunction: ->
    timestamp = @timestamp
    firstDayOfYear = new Date timestamp.getFullYear(), 0, 0, 0, 0, 0
    
    firstDayTime = Math.floor firstDayOfYear.valueOf() / 86400000
    timestampTime = Math.ceil timestamp.valueOf() / 86400000
    timestampDayOfYear = timestampTime - firstDayTime

    averageDayOfYear = (7 * Math.floor(timestampDayOfYear / 7))
    offset = averageDayOfYear - timestampDayOfYear

    timestamp.setDate timestamp.getDate() + offset
    timestamp.setHours 0
    timestamp.setMinutes 0
    timestamp.setSeconds 0

    emit {path: @path, timestamp: timestamp},
      path: @path
      timestamp: timestamp
      counter: @counter
      metric_count: 1

  # Returns the map function appropriate for the specified timespan.
  @mapFunctionForTimespan: (timespanInDays) ->
    if timespanInDays <= 4
      @oneHourAverageMapFunction
    else if timespanInDays <= 7
      @sixHourAverageMapFunction
    else if timespanInDays <= 30
      @twelveHourAverageMapFunction
    else if timespanInDays <= 90
      @oneDayAverageMapFunction
    else if timespanInDays <= 180
      @fourDayAverageMapFunction
    else
      @oneWeekAverageMapFunction

  # Reduce the data yielded by one of the map functions.
  @reduceFunction: (key, values) ->

    result =
      path: key.path
      timestamp: key.timestamp
      counter: 0
      metric_count: 0

    values.forEach (value) ->
      result.counter += value.counter
      result.metric_count += 1

    result

  # Finalize the data yielded by the mapreduce operation, calculating the
  # averages for each metric.
  @finalizeFunction: (key, value) ->
    value.counter = value.counter / value.metric_count
    value

module.exports = MetricMapReduce
