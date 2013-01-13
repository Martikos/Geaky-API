# * GET members listing.

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
mongoose.connect "linus.mongohq.com", "loss", 10039, user: process.env.mongohq_username, pass: process.env.mongohq_password

exports.routes = (app) ->

  app.get "/members", (request, response) ->
    Member.find {}, (err, results) ->
      if err
        console.log "Error!"
        response.send "Fucking error"
      else
        console.log results
        response.send results

  app.get "/members/:login", (request, response) ->
    login = request.param "login"
    Member.find login: login, (err, results) ->
      if err
        console.log err
        response.send err
      else
        console.log results 
        response.send results 
  return


# Database  Functions #
get_members = () ->
  Member.find {}, (err, results) ->
    if err
      console.log err
      return err
    else
      console.log results
      return results

get_member = (login) ->
  Member.find login: login, (err, results) ->
    if err
      console.log err
    else
      console.log results
      return results

delete_member = (login) ->
  Member.find(login: login).remove()


post = (new_member) ->
  new_member.save (err, result) ->
    if err
      console.log err
      return err
    else 
      console.log result
      return result

update_member = (login, new_member) ->
  Member.update login: login, new_member, (err, result) ->
    if err
      console.log err
      return err
    else
      console.log result
      return result

