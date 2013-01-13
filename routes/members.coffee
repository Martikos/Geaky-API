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
        response.send err
      else
        response.send results

  app.get "/members/:login", (request, response) ->
    login = request.param "login"
    Member.find login: login, (err, results) ->
      if err
        response.send err
      else
        response.send results 
  return


# Database  Functions #
get_members = () ->
  Member.find {}, (err, results) ->
    if err
      return err
    else
      return results

get_member = (login, callback) ->
  Member.find login: login, (err, results) ->
    if err
      return callback err, {}
    else
      return callback null, results

delete_member = (login) ->
  Member.find(login: login).remove()

post_member = (member) ->
  Member new_member = 
    login: member.login,
    name: member.name,
    gravatar: member.gravatar,
    blog: member.blog,
    url: member.url,
    followers: member.followers,
    following: member.following,
    stars: member.stars
  new_member.save (err, result) ->
    if err
      return err
    else 
      return result

update_member = (new_member) ->
  Member.update login: new_member.login, { name: new_member.name, blog: new_member.blog, gravatar: new_member.gravatar, url: new_member.url, repos: new_member.repos, following: new_member.following, followers: new_member.followers, stars: new_member.stars}, (err, result) ->
    if err
      return err
    else
      return result

exports.get_members = get_members
exports.get_member = get_member
exports.delete_member = delete_member
exports.post_member = post_member
exports.update_member = update_member

