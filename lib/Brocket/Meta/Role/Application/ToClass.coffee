_           = require "underscore"
Application = require "../Application"
util        = require "util"

class ToClass extends Application
  apply: (role, metaclass) ->
    @_setRole  role
    @_setClass metaclass

    super

    metaclass.addRole role
    metaclass.addRoleApplication @

    return

  # XXX - also need to handle conflicting methods
  _checkRequiredMethods: ->
    missing = []

    for method in @role().requiredMethods()
      continue if @class().hasMethod method.name()
      missing.push method.name

    if missing.length
      noun = if missing.length > 1 then "method" else "methods"
      list = _.map missing.sort().join(", "), (name) ->
        "'#{name}'"

      message = "The #{ @role().name() } role requires the #{noun} #{list}
                 to be implemented by #{ @class().name() }"

      throw new Error message

    return

  _applyAttributes: ->
    metaclass = @class()

    for attr in @role().attributes()
      continue if metaclass.hasAttribute attr.name()
      metaclass.addAttribute attr.attributeForClass()

  role: ->
    return @_role

  _setRole: (role) ->
    @_role = role
    return

  class: ->
    return @_class

  _setClass: (metaclass) ->
    @_class = metaclass
    return
