child  = require "child_process"
fs     = require "fs"
path   = require "path"
muffin = require "muffin"
util   = require "util"

task "build", "compile coffeescript → javascript", (options) ->
  muffin.run
    options: options,
    files: [
      "./lib/**/*.coffee",
      "./tests/**/*.coffee",
    ],
    map:
      "lib/(.+).coffee": (m) ->
        muffin.compileScript m[0], path.join("lib" ,"#{ m[1] }.js"), options
      "tests/(.+).coffee": (m) ->
        muffin.compileScript m[0], path.join("tests" ,"#{ m[1] }.js"), options

task "clean", "clean up any compiled code", (options) ->
  muffin.run
    options: options,
    files: [
      "./lib/**/*.js",
      "./tests/**/*.js",
    ],
    map:
      "(.+)": (m) ->
        fs.unlinkSync m[1]

task "test", "run all tests", (options) ->
  tap = child.spawn "./node_modules/tap/bin/tap.js", [ "--stderr", "./tests" ]
  tap.stdout.on "data", (data) ->
    process.stdout.write data.toString()

  tap.stderr.on "data", (data) ->
    process.stderr.write data.toString()

  tap.on "exit", (code) ->
    process.exit code
