
#
# * GET home page.
# 
exports.index = (app) ->
  app.get '/', (request, response) ->
    response.render "index",
      title: "Lebanese Open Source Initiative"


