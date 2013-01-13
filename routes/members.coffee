#
# * GET members listing.
# 
mongoose = require "mongoose"

member = new Schema
  login: String,
  name: String,
  gravatar: String,
  blog: String,
  followers: Number,
  following: Number,
  stars: Number,
  url: String

Member = mongoose.model "member", member

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
