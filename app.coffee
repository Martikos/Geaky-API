
###
Module dependencies.
###
express = require("express")
routes = require("./routes")
user = require("./routes/members")
http = require("http")
path = require("path")
app = express()
app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler()

routes = require("./routes/members").routes app
index = require("./routes/index").index app

# Dashboard Update #
update_dashboard = require "./logic/update_dashboard"
update_database = update_dashboard.update_database
interval_ms = update_dashboard.interval_ms
update_database()
setInterval update_database, interval_ms


http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

