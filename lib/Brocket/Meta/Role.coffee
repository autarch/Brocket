_                 = require "underscore"
Attribute         = require "./Attribute"
Cache             = require "./Cache"
ConflictingMethod = require "./Role/ConflictingMethod"
HasAttributes     = require "./Mixin/HasAttributes"
HasMethods        = require "./Mixin/HasMethods"
HasRoles          = require "./Mixin/HasRoles"
RequiredMethod    = require "./Role/RequiredMethod"
RoleAttribute     = require "./Role/Attribute"
ToClass           = require "./Role/Application/ToClass"
ToInstance        = null #require "./Role/Application/ToInstance"
ToRole            = null #require "./Role/Application/ToRole"
util              = require "util"

Class = null

class Role
  for own key of HasAttributes.prototype
    Role.prototype[key] = HasAttributes.prototype[key]

  for own key of HasMethods.prototype
    Role.prototype[key] = HasMethods.prototype[key]

  for own key of HasRoles.prototype
    Role.prototype[key] = HasRoles.prototype[key]

  constructor: (args) ->
    @_name = args.name
    throw new Error "You must provide a name when constructing a role" unless @_name

    args.cache = true unless args.cache? && ! args.cache

    # This is necessary to avoid a circular dependency issue between Class &
    # Role. One of them has to be loaded later.
    Class ?= require "./Class"

    util.debug util.inspect args.name

    if args.cache && Cache.metaObjectExists args.name
      meta = Cache.getMetaObject args.name
      unless meta instanceof Role
        message = "Found an existing meta object named #{ args.name } which is not a Role object."
        if meta instanceof Class
          message += " You canont create a Class and a Role with the same name."
        throw new Error message

      return meta

    @_buildMethodProperties args
    @_buildAttributeProperties args

    @_requiredMethods    = []
    @_conflictingMethods = []

    @_requiredMethodClass    = args.requiredMethodClass ? RequiredMethod
    @_conflictingMethodClass = args.conflictingMethodClass ? ConflictingMethod

    @_applicationToClassClass = args.applicationToClassClass ? ToClass

    @_appliedAttributeClass = args.appliedAttributeClass ? Attribute

    @_localRoles = []

    Cache.storeMetaObject @ if args.cache

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
    rmclass = @requiredMethodClass()
    unless method instanceof rmclass
      method = new rmclass name: method

    @requiredMethods().push method

    return;

  addConflictingMethod: (method) ->
    rmclass = @conflictingMethodClass()
    unless method instanceof rmclass
      method = new rmclass name: method

    @conflictingMethods().push method

    return;

  applyRole: (other, args) ->
    args ?= {}

    if other instanceof Class
      (new ToClass args).apply @, other
    else if other instanceof Role
      (new ToRole args).apply @, meta
    else if other instanceof Object
      (new ToInstance).apply @, other
    else
      throw new Error "Cannot apply a role to a #{ other.toString() }"

    return

  _allRoleSources: ->
    seen = {}

    roles = [ @localRoles().slice(0) ]

    while role = roles.shift()
      continue if seen[ role.name() ]
      seen[ role.name() ]  = true
      roles.push role

    return _.values seen

  name: ->
    return @_name

  requiredMethods: ->
    return @_requiredMethods

  requiredMethodClass: ->
    return @_requiredMethodClass

  conflictingMethods: ->
    return @_conflictingMethods

  conflictingMethodClass: ->
    return @_conflictingMethodClass

  applicationToClassClass: ->
    return @_applicationToClassClass

  appliedAttributeClass: ->
    return @_appliedAttributeClass

  localRoles: ->
    @_localRoles

module.exports = Role
