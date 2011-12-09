_         = require "underscore"
Attribute = require "./Attribute"
Method    = require "./Method"
util      = require "util"

class Class
  constructor: (args) ->
    @_name = args.name
    throw "You must provide a name when constructing a class" unless @_name

    @_attributes   = {}
    @_methods      = {}
    @_superclasses = []

    @_attributeClass = args.attributeClass ? Attribute
    @_methodClass    = args.methodClass    ? Method

    @_class = @._makeClass args._class

    return

  _makeClass: (klass) ->
    if !klass
      klass = (params...) ->
          @.constructor.meta().constructInstance @, params

    klass.meta = => @

    klass.prototype._super = ->
      try
        throw new Error
      catch e
        error = e

      meta = @.constructor.meta()
      caller = meta._callerFromError error, "_super"

      for supermeta in meta.superclasses()
        superclass = supermeta.class()
        if Object.prototype.hasOwnProperty.call superclass.prototype, caller
          return superclass.prototype[caller].apply @, arguments

      supernames = _.map meta.superclasses(), (s) -> s.name()

      throw Error "No #{caller} method found in any superclasses of #{ meta.name() } - superclasses are #{ supernames.join(',') }"

    return klass

  setSuperclasses: (supers) ->
    supers = [supers] unless supers instanceof Array

    supers = _.map supers, (klass) =>
      return klass if klass instanceof Class
      return klass.meta() if klass.meta?
      # XXX - throw an error here instead?
      return unless typeof klass == "function"

      return @._newFromClass klass

    @_superclasses = _.filter supers, (klass) -> klass?

    @._checkMetaclassCompatibility()

    for meta in supers
      for own name, prop of meta.class().prototype
        continue if /^_super$/.test(name)
        continue if @.class().prototype[name]?

        @.class().prototype[name] = prop

    return

  @newFromClass = (klass) ->
    name =
      if matches = klass.toString().match( /function\s*(\w+)/ )
        matches[1]
      else
        "__Anon__"

    return new @ ( name: name, _class: klass )

  _newFromClass: (klass) ->
    return @.constructor.newFromClass klass

  addAttribute: (attribute) ->
    if attribute not instanceof Attribute
      aclass = @.attributeClass()
      attribute = new aclass attribute

    @.attributes()[ attribute.name() ] = attribute
    @.addMethod method for method in attribute.methods()

    return attribute

  removeAttribute: (attribute) ->
    delete @.attributes()[ attribute.name() ]
    @.removeMethod method for method in attribute.methods()
    return

  attribute: (name) ->
    return @.attributes()[name]

  hasAttribute: (name) ->
    return @.attribute(name)?

  addMethod: (method) ->
    if method not instanceof Method
      mclass = @.methodClass()
      method = new mclass method

    @.methods()[ method.name() ] = method
    method.attachToClass this
    @.class().prototype[ method.name() ] = method.body()
    return

  removeMethod: (method) ->
    delete @.methods()[ method.name() ]
    method.detachFromClass this
    delete @.class().prototype[ method.name() ]
    return

  hasMethod: (name) ->
    return @.methods()[name]?

  methodNamed: (name) ->
    methods = @.methods()
    return methods[name] if methods[name]?

    if @.class().prototype[name]? && typeof @.class().prototype[name] == "function"
      @.addMethod name: name, body: @.class().prototype[name]

    return methods[name]

  _checkMetaclassCompatibility: (klass) ->
    return

  constructInstance: (instance, params) ->
    params =
      if instance.BUILDARGS?
        instance.BUILDARGS params
      else
        params

    for own name, attr of @.attributes()
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

  name: ->
    @_name

  superclasses: ->
    @_superclasses

  attributes: ->
    @_attributes

  methods: ->
    @_methods

  class: ->
    @_class

  attributeClass: ->
    @_attributeClass

  methodClass: ->
    @_methodClass

module.exports = Class
