#
# * GET members listing.
# 
mongoose = require "mongoose"
Schema = mongoose.Schema

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
mongoose.connect "linus.mongohq.com", "loss", 10039, user: process.env.mongohq_username ,pass: process.env.mongohq_password

exports.routes = (app) ->
  app.get "/members", (req, res) ->
    Member.find {}, (err, res) ->
      if err
        console.log err
      else
        console.log res
    res.send "getting from database"

  app.post "/members", (req, res) ->
    res.send "posting on database"

  app.put "/members", (req, res) ->
    res.send "putting on database"

  app.delete "/members", (req, res) ->
    res.send "deleting from database"

  return
