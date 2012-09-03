#!/usr/bin/env coffee

require 'coffee-script'
global._ = require 'underscore'

moment   = require 'moment'
colors   = require 'colors'
async    = require 'async'
irc      = require 'irc'
program  = require 'commander'
mongoose = require 'mongoose'
cli      = null
status   = {}

mongoose.connect 'mongodb://localhost/irc_kuroko'

set_time = (date) ->
  return (moment date).unix()

get_time = (unixtime) ->
  return moment.unix(unixtime).format('MMM DD YYYY, HH:mm:ss')

LogSchema = new mongoose.Schema
  server : String
  channel: String
  nickname: String
  message: String
  time: type: Number, set: set_time, get: get_time

log = mongoose.model 'logs', LogSchema

program
  .version((require './package.json').vesion)
  .option('-m, --myport <myport>', 'specify the viewer port', Number, 1337)
  .option('-s, --server <address>', 'specify the server', String)
  .option('-p, --port <port>', 'specify the port [6667]', Number, 6667)
  .option('-c, --channels <channelA, channelB, ...>', 'specify channels without #', String)
  .option('-n, --name <nickname>', 'specify the bot name [kuroko]', String, 'kuroko')
  .parse process.argv

async.series [
  (cb) ->
    if !program.server?
      program.prompt 'server: ', (server) ->
        program.server = server
        cb null
    else
      cb null

  , (cb) ->
    if !program.channels?
      program.prompt 'channels: ', (channels) ->
        program.channels = _.map channels.split(','), (channel) ->
          status[channel] = no
          return "##{channel}"
        cb null
    else
      program.channels = _.map program.channels.split(','), (channel) ->
        status[channel] = no
        return "##{channel}"
      cb null

  , (cb) ->
    console.log "\n\n"
    console.log 'Server: ', (String program.server).green
    console.log 'Port: ', (String program.port).green
    console.log 'Channel: ', (String JSON.stringify program.channels).green
    console.log "My name is #{program.name}, try to connect IRC.".cyan
    cb null

  , (cb) ->
    cli = new irc.Client program.server, program.name,
      channels: program.channels
    cli.addListener 'message', (from, ch, msg) ->

      if msg.match /(ログ|ろぐ|log).*(とっ|とれ|取っ|取れ|スタ|start)/
        if status[ch]
          status[ch] = yes
          cli.say ch, "もうログとってますの"
        else
          status[ch] = yes
          cli.say ch, "ログとりますの"
      else if msg.match /(ログ|ろぐ|log).*(やめ|止|スト|stop)/
        if status[ch]
          status[ch] = no
          cli.say ch, "ログとるのやめますの"
        else
          status[ch] = no
          cli.say ch, "まだログとってないですの"
      else if msg.match new RegExp "#{program.name}", 'g'
        cli.say ch, 'はいですの'
      else if status[ch]
        (new log
          server : "#{program.server}:#{program.port}"
          channel: ch
          nickname: from
          message: msg
          time: new Date()
        ).save()

    cb null

  , (cb) ->
    http     = require 'http'
    routes   = require './routes'
    express  = require 'express'
    app      = express()

    app.configure ->
      app.set 'port', process.env.PORT || 3000
      app.set 'views', "#{__dirname}/views"
      app.set 'view engine', 'jade'
      app.use express.favicon()
      app.use express.logger 'dev'
      app.use express.bodyParser()
      app.use express.methodOverride()
      app.use express.compress()
      app.use app.router
      app.use require('less-middleware') "#{__dirname}/public"
      app.use require('coffee-middleware') "#{__dirname}/public"
      app.use express.static "#{__dirname}/public"
      app.use routes.failed

    app.configure 'development', ->
      app.use express.errorHandler()

    routes.configure log
    app.get '/', routes.index
    app.get '/log/:server', routes.server
    app.get '/log/:server/:channel', routes.channel

    http.createServer(app).listen app.get('port'), ->
     console.log "\n\n"
     console.log "Kuroko listening on port #{app.get 'port'}"
    cb null
]
