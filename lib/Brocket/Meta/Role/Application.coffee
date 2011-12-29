_       = require "underscore"
Helpers = require "../../Helpers"
util    = require "util"

class Application
  constructor: (args) ->
    @__methodAliases = args["-aliases"] ? {}

    @__methodExclusions =
      if args["-excludes"]?
        Helpers.arrayToObject args["-excludes"]
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
    return @_methodAliases()[name]?

  aliasForMethod: (name) ->
    return @_methodAliases()[name]

  _methodAliases: ->
    @__methodAliases

  methodIsExcluded: (name) ->
    return @_methodExclusions()[name]?

  _methodExclusions: ->
    @__methodExclusions

module.exports = Application
