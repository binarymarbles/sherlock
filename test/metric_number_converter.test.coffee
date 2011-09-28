testCase = (require 'nodeunit').testCase
require 'date-utils'

TestHelper = require './test_helper'
MetricNumberConverter = require '../lib/metric_number_converter'

module.exports = testCase
  setUp: (callback) ->

    # Create a fake data set,
    @dataSet =
      'test.metric': [
        { timestamp: new Date().addSeconds(-1), value: 1000000 }
        { timestamp: new Date(), value: 1000000 }
      ]

    # Create a converter for the data set.
    @converter = new MetricNumberConverter @dataSet

    callback()

  'bytes to MbitPerSecond': (test) ->
    result = @converter.applyConversion 'bytesToMbitPerSecond'
    test.equals result['test.metric'][0].value, 0
    test.equals result['test.metric'][1].value, 7.63
    test.done()

  'bytes to MB': (test) ->
    result = @converter.applyConversion 'bytesToMB'
    test.equals result['test.metric'][0].value, 0.95
    test.equals result['test.metric'][1].value, 0.95
    test.done()
