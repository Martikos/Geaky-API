fs = require "fs"
async = require "async"
request = require "request"
member_module = require "../routes/members"

interval_mins = 10 # update interval in minutes

exports.interval_ms = interval_ms = interval_mins * 60 * 1000

# Helpers 

compare = (old_user, new_user, callback) ->
  if old_user.name is new_user.name and old_user.login is new_user.login and old_user.blog is new_user.blog and old_user.gravatar is new_user.gravatar and old_user.followers is new_user.followers and old_user.following is new_user.following and old_user.stars is new_user.stars and old_user.repos is new_user.repos
    return true
  else
    return false

create = (member) ->
  user =
    login : member.login,
    name : member.name,
    gravatar : member.gravatar,
    blog : member.blog,
    url : member.url,
    repos : member.repos,
    following : member.following,
    followers : member.followers,
    repos: member.repos,
    stars : member.stars
  user
  

exports.update_database = ->

  console.log "Updating Database ... "
  users = []

  org_url = "https://api.github.com/orgs/Lebanese-OSS/members" + "?&per_page=100&client_id=" + process.env.github_clientid + "&client_secret=" + process.env.github_clientsecret
  reset = (members, callback) ->
    count = 0
    new_members = []
    members.forEach (member) ->
      member_url = "https://api.github.com/users/" + member.login + "?&per_page=100&client_id=" + process.env.github_clientid + "&client_secret=" + process.env.github_clientsecret
      request member_url, (error, response, body) ->
        if error
          console.log "Could Not Get " + member.login + " User Information: " + error
        else
          try 
            member = JSON.parse(body)
            member.starred_count = 0
            new_members.push member
            count++
            callback new_members  if count is members.length
          catch e
            console.log "JSON Parse Error: Bad Response."

  request org_url, (error, response, body) ->
    try 
      members = JSON.parse(body)
      reset members, (members) ->
        index = 0
        async.whilst (->
          index < members.length
        ), ((callback) ->
          FinishedQuery = undefined
          Repos = undefined
          page = undefined
          Repos = []
          FinishedQuery = false
          page = 1
          async.whilst (->
            not FinishedQuery
          ), ((callback) ->
            url = undefined
            url = "https://api.github.com/users/" + members[index].login + "/starred?page=" + page + "&per_page=100&client_id=" + process.env.github_clientid + "&client_secret=" + process.env.github_clientsecret
            request url, (error, response, body) ->
              if not error and response.statusCode is 200 and body.length > 2
                try 
                  JSON.parse(body).forEach (newRepo) ->
                    Repos.push newRepo
                    members[index].starred_count++
                    Repos.push newRepo

                  Repos.forEach (repo) ->
                    repo

                  page++
                  callback()
                catch e
                  console.log "JSON Parse Error: Bad Response."
              else
                FinishedQuery = true
                callback()

          ), (err) ->
            index++
            callback()

        ), (err) ->
          members.forEach (member) ->

            new_user = {}
            new_user.login = member.login
            new_user.name = if member.name? then member.name else ""
            new_user.gravatar = if member.gravatar_id? then member.gravatar_id else ""
            new_user.blog = if member.blog? then member.blog else ""
            new_user.url = if member.html_url? then member.html_url else ""
            new_user.repos = member.public_repos
            new_user.following = member.following
            new_user.followers = member.followers
            new_user.stars = member.starred_count

            member_module.get_member new_user.login, (err, old_user) ->
              if err
                console.log err
              else 
                if !old_user
                  console.log "Adding User: " + new_user.login
                  member_module.post_member new_user
                else
                  if !compare old_user, new_user
                    console.log "Updating User: " + new_user.login
                    member_module.update_member new_user
    catch e
      "JSON Parse Error: Bad Response."

