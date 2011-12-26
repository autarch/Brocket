_    = require "underscore"
util = require "util"

class RequiredMethod
  constructor: (args) ->
    @_name = args.name

    return

  name: ->
    @_name

module.exports = RequiredMethod
