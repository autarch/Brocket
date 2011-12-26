_      = require "underscore"
Method = require "../Method"
util   = require "util"

class HasMethods
  _buildMethodProperties: (args) ->
    @_methods     = {}
    @_methodClass = args.methodClass ? Method

  addMethod: (method) ->
    if method not instanceof Method
      mclass = @methodClass()
      method = new mclass method

    @_methodsObj()[ method.name() ] = method
    method.attachToClass this
    @class().prototype[ method.name() ] = method.body()
    return

  removeMethod: (method) ->
    delete @_methodsObj()[ method.name() ]
    method.detachFromClass this
    delete @class().prototype[ method.name() ]
    return

  hasMethod: (name) ->
    return @methods()[name]?

  methodNamed: (name) ->
    methods = @_methodsObj()
    return methods[name] if methods[name]?

    if @class().prototype[name]? && typeof @class().prototype[name] == "function"
      @addMethod name: name, body: @class().prototype[name]

    return methods[name]

  # XXX - once there's an immutabilization hook this method should just cache
  # the methods
  methods: ->
    for own name, body of @class().prototype
      continue if @_methodsObj()[name]
      # XXX - this is kind of gross - maybe have some sort of way of marking a
      # method as hidden or something?
      continue if name == "_super"

      @addMethod name: name, body: @class().prototype[name], source: @

    return @_methodsObj()

  _methodsObj: ->
    @_methods

  methodClass: ->
    @_methodClass

module.exports = HasMethods