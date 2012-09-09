`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define (require) ->
  _              = require "underscore"
  RequiredMethod = require "./RequiredMethod"
  util           = require "util"

  class ConflictingMethod extends RequiredMethod
    constructor: (args) ->
      super

      @_roles = args.roles

      return

    roles: ->
      return @_roles
