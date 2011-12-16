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
    @_buildMethodProperties args
    @_buildAttributeProperties args

    @_name = args.name
    throw "You must provide a name when constructing a class" unless @_name

    @_superclasses = []

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

      for supermeta in meta.superclasses()
        superclass = supermeta.class()
        if Object.prototype.hasOwnProperty.call superclass.prototype, caller
          return superclass.prototype[caller].apply @, arguments

      supernames = _.map meta.superclasses(), (s) -> s.name()

      throw Error "No #{caller} method found in any superclasses of #{ meta.name() } - superclasses are #{ supernames.join(',') }"

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

module.exports = Class
