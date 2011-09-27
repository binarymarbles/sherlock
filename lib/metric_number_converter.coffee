class MetricNumberConverter

  constructor: (dataSet) ->
    @dataSet = dataSet

  applyConversion: (method) ->
    if typeof(@[method]) == undefined
      throw "Unknown conversion method: #{method}"
    @[method]()

  # Convert bytes to Mbit per second.
  bytesToMbitPerSecond: ->
    @convertMetrics (metric, previousMetric) ->

      # Calculate the difference between the timestamp on the previous metric
      # and this metric in seconds.
      timeDifference = 0

      if previousMetric?
        currentTime = metric.timestamp.valueOf() / 1000
        previousTime = previousMetric.timestamp.valueOf() / 1000
        timeDifference = currentTime - previousTime

      metric.value = (metric.value * 8) / 1024 / 1024 # 1 byte = 8 bits / 1024 = kbits / 1024 = mbits
      metric.value = if timeDifference > 0 then metric.value / timeDifference else 0 # mbits per second
      metric

  # Convert bytes to MB
  bytesToMB: ->
    @convertMetrics (metric) ->

      # 1 byte / 1024 = kb / 1024 = mb
      metric.value = metric.value / 1024 / 1024
      metric

  # Generic method to convert all metrics in the data set.
  convertMetrics: (conversionCallback) ->
    for key, metrics of @dataSet

      previousMetric = null
      for metric in metrics

        # This is the best way I could find to round a number value to two
        # decimal points. The implementation is as charming as a school bus
        # fire.
        metric = conversionCallback(metric, previousMetric)
        metric.value = Math.round(metric.value * 100) / 100

        previousMetric = metric

    @dataSet


module.exports = MetricNumberConverter
