_              = require "underscore"
Attribute      = require "./Attribute"
HasAttributes  = require "./Mixin/HasAttributes"
HasMethods     = require "./Mixin/HasMethods"
RequiredMethod = require "./Role/RequiredMethod"
RoleAttribute  = require "./Role/Attribute"
ToClass        = require "./Role/Application/ToClass"
util           = require "util"

class Role extends HasMethods
  for own key of HasAttributes.prototype
    Role.prototype[key] = HasAttributes.prototype[key]

  for own key of HasMethods.prototype
    Role.prototype[key] = HasMethods.prototype[key]

  constructor: (args) ->
    @_name = args.name
    throw "You must provide a name when constructing a role" unless @_name

    @_buildMethodProperties args
    @_buildAttributeProperties args

    @_requiredMethodClass = args.requiredMethodClass ? RequiredMethod

    @_applicationToClassClass = args.applicationToClassClass ? ToClass

    @_appliedAttributeClass = args.appliedAttributeClass ? Attribute

    @_requiredMethods = []

    return

  _defaultAttributeClass: ->
    RoleAttribute

  _attachAttribute: (attr) ->
    attr.attachToRole @
    return

  _detachAttribute: (attr) ->
    attr.detachFromRole @
    return

  _attachMethod: (method) ->
    method.attachToMeta @
    return

  _detachMethod: (method) ->
    method.detachFromMeta @
    return

  # Unlike a class, methods can only be added to a role explicitly, so we
  # don't need to check an associated prototype for implicit methods.
  _methodMap: ->
    return @_methodsObj()

  addRequiredMethod: (method) ->
    if method instanceof String
      rmclass = @requiredMethodClass()
      method = new rmclass name: method

    @requiredMethods().push method

    return;

  name: ->
    return @_name

  requiredMethods: ->
    return @_requiredMethods

  requiredMethodClass: ->
    return @_requiredMethodClass

  applicationToClassClass: ->
    return @_applicationToClassClass

  appliedAttributeClass: ->
    return @_appliedAttributeClass

module.exports = Role
