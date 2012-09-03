logger = null

exports.configure = (log) ->
  logger = log

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

exports.failed = (req, res) ->
  res.status 404
  res.render '404'
    req: req
