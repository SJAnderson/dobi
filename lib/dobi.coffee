# dependencies
Firebase = require 'firebase'
fs = require 'fs'
open = require 'open'
optimist = require 'optimist'
readline = require 'readline'

# usage
USAGE = """
Usage: dobi <command> [command-specific-options]

where <command> [command-specific-options] is one of:
  create <my-app>                 create a new app
  deploy <my-app>                 deploy an app (COMING SOON)
  init                            initialize a workspace
  install <my-app> <site-slug>    create a site using your app
  login                           authenticate your user
  open <site-slug>                open a site
  run                             run a development server
  start                           daemonize a development server
  stop                            stop a daemonized development server
  version                         check your dobi version
  whoami                          check your authentication status
"""

# constants
CWD = process.cwd()
FIREBASE_URL = 'https://lessthan3.firebaseio.com'
USER_HOME = process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE
USER_CONFIG_PATH = "#{USER_HOME}/.lt3_config"

# helpers
rl = readline.createInterface {
  input: process.stdin
  output: process.stdout
}

exit = (msg) ->
  log msg if msg
  process.exit()

log = (msg) ->
  console.log "[dobi] #{msg}"

login = (require_logged_in, next) ->
  [require_logged_in, next] = [false, require_logged_in] unless next

  log 'authenticating user'
  readUserConfig (config) ->
    if config.user
      next config
    else if not require_logged_in
      next null
    else
      log 'not logged in: must authenticate'
      log 'opening login portal in just a few moments'
      setTimeout ( ->
        open 'http://www.dobi.io/auth'
        rl.question "Enter Token: ", (token) ->
          exit 'must specify token' unless token
          fb = new Firebase FIREBASE_URL
          fb.auth token, (err, data) ->
            exit 'invalid token' if err
            config.user = data.auth
            config.token = token
            config.token_expires = data.expires
            saveUserConfig config, ->
              next config
      ), 3000

readUserConfig = (next) ->
  fs.exists USER_CONFIG_PATH, (exists) ->
    if exists
      fs.readFile USER_CONFIG_PATH, 'utf8', (err, data) ->
        exit 'unable to read user config' if err
        next JSON.parse data
    else
      saveUserConfig {}, ->
        next {}

saveUserConfig = (data, next) ->
  config = JSON.stringify data
  fs.writeFile USER_CONFIG_PATH, config, 'utf8', (err) ->
    exit 'unable to write user config' if err
    next()

# get arguments and options
argv = optimist.argv._
command = argv[0]
args = argv[1...argv.length]
opts = optimist.argv

switch command

  # create a new app
  when 'create'
    exit 'not available yet'

  # deploy an app
  when 'deploy'
    exit 'not available yet'

  # initialize a workspace
  when 'init'
    exit 'not available yet'

  # create a site using your app
  when 'install'
    exit 'not available yet'

  # authenticate your user
  when 'login'
    login true, (user) ->
      exit JSON.stringify user, null, 2 if user
      exit 'not logged in. try "dobi login"'

  # open a site
  when 'open'
    exit 'not available yet'

  # run a development server
  when 'run'
    exit 'not available yet'

  # daemonize a development server
  when 'start'
    exit 'not available yet'

  # daemonize a development server
  when 'stop'
    exit 'not available yet'

  # check your dobi version
  when 'version'
    exit 'not available yet'

  # check your authentication status
  when 'whoami'
    login (user) ->
      exit JSON.stringify user, null, 2 if user
      exit 'not logged in. try "dobi login"'

  # invalid command
  else
    exit "invalid command: #{command}"
