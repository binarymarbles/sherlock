SnapshotParser = require '../lib/snapshot_parser'

module.exports = (app) ->

  # URL used by Watson agents to post snapshot information to Sherlock.
  app.post '/watson/snapshot', (req, res) ->
    new SnapshotParser req.body.payload, (error, snapshot) ->

      if error?
        console.log 'Handling watson snapshot failed, error is', error.message
        res.writeHead 422, 'Content-Type': 'text/plain'
        res.end "ERROR: #{error.message}"

      else

        console.log 'Successfully handled Watson snapshot, stored with ID', snapshot.id, 'and key', snapshot.key
        res.writeHead 200, 'Content-Type': 'text/plain'
        res.end "OK: #{snapshot.id}"
