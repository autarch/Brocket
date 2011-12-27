_       = require "underscore"
Helpers = require "../../Helpers"
util    = require "util"

class Application
  constructor: (args) ->
    @_aliases    =
      if args["-aliases"]?
        Helpers.arrayToObject args["-aliases"]
      else
        {}

    @_exclusions    =
      if args["-exclusions"]?
        Helpers.arrayToObject args["-exclusions"]
      else
        {}

    return

  apply: ->
    @_checkRequiredMethods()

    @_applyAttributes()
    @_applyMethods()

#    @_applyOverrideMethodModifiers()
#    @_applyBeforeMethodModifiers()
#    @_applyAroundMethodModifiers()
#    @_applyAfterMethodModifiers()

    return

  methodIsAliased: (name) ->
    return @_method_aliases()[name]?

  aliasForMethod: (name) ->
    return @_method_aliases()[name]

  methodIsExcluded: (name) ->
    return @_method_exclusions()[name]?

  method_aliases: ->
    return _.values @_method_aliases()

  _method_aliases: ->
    @_aliases

  method_exclusions: ->
    return _.values @_method_exclusions()

  _method_exclusions: ->
    @_exclusions

module.exports = Application
