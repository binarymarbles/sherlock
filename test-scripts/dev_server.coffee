child_process = require 'child_process'
fs = require 'fs'
sys = require 'sys'

class DevServer

  constructor: ->
    @process = null
    @files = []
    @restarting = false

  restart: ->
    @restarting = true
    sys.debug 'DEVSERVER: Stopping server for restart'
    @process.kill()

  start: ->
    sys.debug 'DEVSERVER: Starting server'
    @watchFiles()

    @process = child_process.spawn process.ARGV[0], ['app.coffee']

    @process.stdout.addListener 'data', (data) ->
      process.stdout.write data

    @process.stderr.addListener 'data', (data) ->
      sys.print data

    @process.addListener 'exit', (code) =>
      sys.debug 'DEVSERVER: Child process exited: ' + code
      @process = null
      if @restarting
        @restarting = true
        @unwatchFiles()
        @start()

  watchFiles: ->
    child_process.exec 'find . | grep "\.coffee$"', (error, stdout, stderr) =>
      files = stdout.trim().split "\n"
      files.forEach (file) =>
        @files.push file
        fs.watchFile file, {interval : 500}, (current, previous) =>
          if current.mtime.valueOf() != previous.mtime.valueOf() || current.ctime.valueOf() != previous.ctime.valueOf()
            sys.debug 'DEVSERVER: Restarting because of changed file at ' + file
            @restart()

  unwatchFiles: ->
    @files.forEach (file) ->
      fs.unwatchFile file
    @files = []

new DevServer().start()
