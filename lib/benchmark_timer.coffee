class BenchmarkTimer

  constructor: (description) ->
    @description = description
    @start = new Date().valueOf() / 1000

  end: ->
    end = new Date().valueOf() / 1000
    duration = Math.round(((end - @start) * 100)) / 100
    # console.log 'Task', @description, 'completed in', duration, 'seconds'

module.exports = BenchmarkTimer
