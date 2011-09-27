async = require 'async'
mongoose = require 'mongoose'
connection = require '../lib/db_connection'

TestHelper = require '../test/test_helper'
TestHelper.resetCollections ->
  console.log 'All collections are reset.'
  process.nextTick ->
    mongoose.disconnect()
