_           = require "underscore"
Application = require "../Application"
util        = require "util"

class ToClass extends Application
  apply: (role, metaclass) ->
    @_role  = role
    @_class = metaclass

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

    return

  _applyMethods: ->
    metaclass = @class()

    for method in @role().methods()
      @_applyMethod method
      @_applyMaybeAliasedMethod method

    return

  _applyMethod: (method) ->
    return if @methodIsExcluded method.name()

    existingMethod = @class().methodNamed method.name()
    if existingMethod? && existingMethod.body().toString() != method.body().toString()
      return

    @class().addMethod method.clone()

  _applyMaybeAliasedMethod: (method) ->
    return unless @methodIsAliased method.name()

    aliasedName = @aliasForMethod method.name()

    existingMethod = @class().methodNamed aliasedName

    if existingMethod? && existingMethod.body().toString() != method.body().toString()
      message = "Cannot create a method alias if a local method of the same name exists - #{aliasedName}"
      throw new Error message

    @class().addMethod method.clone name: aliasedName

    return

  role: ->
    return @_role

  class: ->
    return @_class

module.exports = ToClass
