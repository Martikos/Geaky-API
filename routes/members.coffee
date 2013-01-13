#
# * GET members listing.
# 

exports.routes = (app) ->
  app.get "/members", (req, res) ->
    res.send "getting from database"

  app.post "/members", (req, res) ->
    res.send "posting on database"

  app.put "/members", (req, res) ->
    res.send "putting on database"

  app.delete "/members", (req, res) ->
    res.send "deleting from database"

  return
