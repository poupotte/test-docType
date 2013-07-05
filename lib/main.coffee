# This program is suited only to manage your cozy installation from the inside
# Moreover app management works only for apps make by Cozy Cloud company.
# If you want a friendly application manager you should use the
# appmanager.coffee script.

require "colors"

program = require 'commander'
async = require "async"
fs = require "fs"
exec = require('child_process').exec

Client = require("request-json").JsonClient

dataSystemUrl = "http://localhost:9101/"

client = new Client(dataSystemUrl)



program
  .version('1.0.4')
  .usage('<action> <app>')

program
    .command("add_user <password>")
    .description("Add user in DS")
    .action (password) ->
        app =
            "email": 'test@cozycloud.cc'
            "password": password
            "docType": "User"
        console.log "Add user with password #{password}..."
        client.setBasicAuth "proxy", "haibu"
        client.post 'user/', app, (err, res, body)  ->
            if err or body.error?
                console.log "Add failed, Error : "
                console.log body.error
            else
                console.log "User successfully installed"

program
    .command("login <password>")
    .description("Log in user")
    .action (password) ->
        data = password: password
        client.setBasicAuth "proxy", "haibu"
        client.post 'accounts/password/', data, (err, res, body)  ->
            if err or body.error?
                console.log "Log in failed, Error : "
                console.log err
            else
                console.log "Log in"


program
    .command("add <name> <token> <docType>")
    .description("Add application in DS")
    .action (name, token, docType) ->
        app =
            "name": name
            "password": token
            "docType": "Application"
            "permissions": {}
        app.permissions[docType] = "authorized"
        console.log "Add application #{name} with token #{token}..."
        client.setBasicAuth "home", "haibu"
        client.post 'data/', app, (err, res, body)  ->
            if err or body.error?
                console.log "Install failed, Error : "
                console.log body.error
            else
                console.log "#{name} successfully installed"


program
    .command("request <name> <token> <docType>")
    .description("Request DS")
    .action (name, token, docType) ->
        data =
            "value": "val"
            "docType": docType
        client.setBasicAuth name, token
        client.post 'data/', data, (err, res, body)  ->
            if err or body.error?
                console.log "#{name} cannot access to docType #{docType}"
                console.log "response code is : #{res.statusCode}"
            else
                console.log "#{name} can access to docType #{docType}"
                console.log "response code is : #{res.statusCode}"

program
    .command("add_doc_with_password <name> <token> <docType> <password>")
    .description("Add document with password in DS")
    .action (name, token, docType, password) ->
        data =
            "value": "val"
            "password": password
            "docType": docType
        client.setBasicAuth name, token
        client.post 'data/', data, (err, res, body)  ->
            if err or body.error?
                console.log "#{name} cannot access to docType #{docType}"
                console.log "response code is : #{res.statusCode}"
            else
                console.log "#{name} can access to docType #{docType}"
                console.log "document id : #{body._id}"

program
    .command("get_doc_with_password <name> <token> <id>")
    .description("Get document with password in DS")
    .action (name, token, id) ->
        client.setBasicAuth name, token
        client.get "data/#{id}/", (err, res, body)  ->
            if err or body.error?
                console.log "#{name} cannot access to document #{id}"
                console.log "response code is : #{res.statusCode}"
            else
                console.log "document is : "
                console.log body


program
    .command("*")
    .description("Display error message for an unknown command.")
    .action ->
        console.log 'Unknown command, run "cozy-monitor --help"' + \
                    ' to know the list of available commands.'

program.parse process.argv
