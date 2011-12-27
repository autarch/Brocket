_      = require "underscore"
Method = require "../Method"
util   = require "util"

class HasMethods
  _buildMethodProperties: (args) ->
    @__methodsObj = {}
    @_methodClass = args.methodClass ? Method

  addMethod: (method) ->
    if method not instanceof Method
      mclass = @methodClass()
      method.source ?= @
      method = new mclass method

    @_methodsObj()[ method.name() ] = method
    @_attachMethod method

    return

  removeMethod: (method) ->
    method = @methodNamed method unless method instanceof Method

    delete @_methodsObj()[ method.name() ]
    method.detachFromMeta @
    delete @class().prototype[ method.name() ]

    return

  hasMethod: (name) ->
    return @_methodMap()[name]?

  methodNamed: (name) ->
    return @_methodMap[name]

  _methodsObj: ->
    @__methodsObj

  methodClass: ->
    @_methodClass

module.exports = HasMethods