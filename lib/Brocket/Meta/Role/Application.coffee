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
    @_check_required_methods()

    @_apply_attributes()
    @_apply_methods()

#    @_apply_override_method_modifiers()
#    @_apply_before_method_modifiers()
#    @_apply_around_method_modifiers()
#    @_apply_after_method_modifiers()

    return

  isMethodAliased: (name) ->
    return @_method_aliases()[name]?

  isMethodExcluded: (name) ->
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
