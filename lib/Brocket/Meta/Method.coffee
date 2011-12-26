_    = require "underscore"
util = require "util"

class Method
  constructor: (args) ->
    @_name            = args.name
    @_body            = args.body
    @_source          = args.source
    @_associatedClass = args.metaclass

    return

  clone: (args) ->
    args ?= {}

    for prop in [ "name", "body" ]
      args[prop] ?= @[prop]()

    args.source = @source()

    constructor = @constructor

    return new constructor args

  attachToClass: (metaclass) ->
    @_setAssociatedClass metaclass
    return

  detachFromClass: (metaclass) ->
    @_clearAssociatedClass()
    return

  name: ->
    return @_name

  body: ->
    return @_body

  source: ->
    return @_source

  associatedClass: ->
    return @_metaclass

  _setAssociatedClass: (metaclass) ->
    @_associatedClass = metaclass
    return

  _clearAssociatedClass: ->
    delete @_associatedClass
    return

module.exports = Method
