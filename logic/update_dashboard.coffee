async = require "async"
fs = require "fs"
request = require "request"

interval_mins = 1 # update interval in minutes

exports.interval_ms = interval_ms = interval_mins * 60 * 1000

exports.update_database = ->

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
          member = JSON.parse(body)
          member.starred_count = 0
          new_members.push member
          count++
          callback new_members  if count is members.length

  request org_url, (error, response, body) ->
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
              JSON.parse(body).forEach (newRepo) ->
                Repos.push newRepo
                members[index].starred_count++
                Repos.push newRepo

              Repos.forEach (repo) ->
                repo

              page++
              callback()
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
          new_user.gravatar = if member.avatar_url? then member.avatar_url else ""
          new_user.blog = if member.blog? then member.blog else ""
          new_user.url = if member.html_url? then member.html_url else ""
          new_user.repos = member.public_repos
          new_user.following = member.following
          new_user.followers = member.followers
          new_user.stars = member.starred_count

          request.get "http://loss-api.herokuapp.com/members?login=" + new_user.login, (err, res, body) ->
            results = JSON.parse(body)
            if results.length is 0
              request.post "http://loss-api.herokuapp.com/members",
                headers:
                  "dpd-ssh-key": process.env.dpd_key

                form: new_user
              , (err, res, body) ->
                if err or JSON.parse(body).status is 401
                  console.log "Error Posting User " + member.login + " : " + body
                else
                  console.log "Added User: " + new_user.login

            else
              old_user = create(results[0])
              if old_user isnt `undefined` and not compare(old_user, new_user)
                request.put "http://loss-api.herokuapp.com/members?id=" + old_user.id,
                  headers:
                    "dpd-ssh-key": process.env.dpd_key

                  form: new_user
                , (err, res, body) ->
                  if err or JSON.parse(body).status is 401
                    console.log "Error Updating User " + member.login + " : " + body
                  else
                    console.log "Updated User: " + old_user.login

        fs.writeFile "users", JSON.stringify(members), (err) ->
          if err
            console.log err
          else
            date = new Date()
            console.log "File updated - " + date

compare = (oldmember, newmember) ->
  if oldmember.name is newmember.name and oldmember.login is newmember.login and oldmember.blog is newmember.blog and oldmember.followers is newmember.followers and oldmember.following is newmember.following and oldmember.stars is newmember.stars
    true
  else
    false

create = (member) ->
  user =
    id : memberid
    login : memberlogin
    name : membername
    gravatar : membergravatar
    blog : memberblog
    url : memberurl
    repos : memberrepos
    following : memberfollowing
    followers : memberfollowers
    stars : memberstars
  user
