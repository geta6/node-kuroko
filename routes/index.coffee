logger = null
client = null

exports.configure = (log, cli) ->
  logger = log
  client = cli

exports.index = (req, res) ->
  logger.find {}, (e, data) ->
    server_list = _.uniq _.map(data, (val) -> return "/log/#{val.server}"), yes
    res.render 'index'
      crumb: no
      title: 'Server'
      items: server_list

exports.server = (req, res) ->
  server = req.param 'server'
  logger.find server: server, (e, data) ->
    channel_list = _.uniq _.map(data, (val) -> return "/log/#{server}/#{val.channel.substring 1}"), yes
    res.render 'index'
      crumb: "/"
      title: 'Channel'
      items: channel_list

exports.channel = (req, res) ->
  max = req.query.max || 100
  page = req.query.page || 1
  skip = (max + 1) * (page - 1)
  limit = max + 2
  server = req.param 'server'
  channel = req.param 'channel'
  logger.find({server: server, channel: "##{channel}"}).sort('-time').skip(skip).limit(limit).exec (e, data) ->
    res.render 'index'
      max: max
      page: page
      crumb: "/log/#{server}"
      title: "Log #{server}##{channel}"
      items: data

exports.chjoin = (req, res) ->
  channel = req.param 'channel' || no
  if channel
    client.join "##{channel}"
    res.writeHead 200, 'Content-Type': 'application/json'
    res.end()
  else
    res.render 'join'

exports.failed = (req, res) ->
  res.status 404
  res.render '404'
    req: req
