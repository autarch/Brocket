_             = require "underscore"
Attribute     = require "./Attribute"
HasAttributes = require "./Mixin/HasAttributes"
HasMethods    = require "./Mixin/HasMethods"
util          = require "util"

class Class
  for own key of HasAttributes.prototype
    unless Object.prototype.hasOwnProperty Class.prototype, key
      Class.prototype[key] = HasAttributes.prototype[key]

  for own key of HasMethods.prototype
    unless Object.prototype.hasOwnProperty Class.prototype, key
      Class.prototype[key] = HasMethods.prototype[key]

  constructor: (args) ->
    @_name = args.name
    throw "You must provide a name when constructing a class" unless @_name

    @_buildMethodProperties args
    @_buildAttributeProperties args

    @_superclasses = []

    @_roles = []
    @__roleApplications = []

    @_class = @_makeClass args._class

    return

  _makeClass: (klass) ->
    if !klass
      klass = (params...) ->
          @constructor.meta().constructInstance @, params

    klass.meta = => @

    klass.prototype._super = ->
      error = new Error

      meta = @constructor.meta()
      caller = meta._callerFromError error, "_super"

      ancestors = meta.linearizedInheritance()
      for supermeta in ancestors
        superclass = supermeta.class()
        if Object.prototype.hasOwnProperty.call superclass.prototype, caller
          return superclass.prototype[caller].apply @, arguments

      supernames = _.map ancestors, (s) -> s.name()

      throw Error "No #{caller} method found in any superclasses of #{ meta.name() } - superclasses are #{ supernames.join(', ') }"

    return klass

  @newFromClass = (klass) ->
    name =
      if matches = klass.toString().match( /function\s*(\w+)/ )
        matches[1]
      else
        "__Anon__"

    return new @ ( name: name, _class: klass )

  _newFromClass: (klass) ->
    return @constructor.newFromClass klass

  setSuperclasses: (supers) ->
    supers = [supers] unless supers instanceof Array

    supers = _.map supers, (klass) =>
      return klass if klass instanceof Class
      return klass.meta() if klass.meta?
      # XXX - throw an error here instead?
      return unless typeof klass == "function"

      return @_newFromClass klass

    @_superclasses = _.filter supers, (klass) -> klass?

    @_checkMetaclassCompatibility()

    for meta in @_superclasses
      for own name, method of meta.methods()
        continue if @hasMethod name
        @addMethod method.clone()

    return

  _checkMetaclassCompatibility: (klass) ->
    return

  constructInstance: (instance, params) ->
    params =
      if instance.BUILDARGS?
        instance.BUILDARGS params
      else
        params

    for own name, attr of @attributes()
      attr.initializeInstanceSlot instance, params

    instance.BUILDALL params if instance.BUILDALL?

    return instance

  # XXX - this needs to be redone to use the C3 algorithm
  linearizedInheritance: ->
    metas = [];

    for supermeta in @superclasses()
      metas.push supermeta;

      for meta in supermeta.linearizedInheritance()
        metas.push meta

    return metas

  addRole: (role) ->
    @_roles().push role

    return

  doesRole: (role) ->
    name =
     if role instanceof Role
        role.name()
      else
        role

    for role in @roles()
      return true if role.name == name

    return false

  roles: ->
    roles = []

    seen = {}

    for meta in @linearizedInheritance()
      for role in meta.localRoles()
        continue if seen[ role.name() ]
        seen[ role.name() ] = true
        roles.push role

    return roles

  addRoleApplication: (application) ->
    @_roleApplications().push application

    return

  _callerFromError: (error, ignoreBefore) ->
    re = new RegExp "\\.#{ignoreBefore} \\("
    for line in error.stack.split /\n+/
      if re.test(line)
        next = true
        continue
      else
        continue unless next
        return line.match( /\.(\w+) \(/ )[1]

    return

  _defaultAttributeClass: ->
    Attribute

  name: ->
    @_name

  superclasses: ->
    @_superclasses

  class: ->
    @_class

  localRoles: ->
    @_roles

  _roleApplications: ->
    @__roleApplications

module.exports = Class
