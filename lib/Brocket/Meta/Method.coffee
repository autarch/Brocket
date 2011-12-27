_    = require "underscore"
util = require "util"

class Method
  constructor: (args) ->
    @_name           = args.name
    @_body           = args.body
    @_source         = args.source
    @_associatedMeta = args.associatedMeta

    return

  clone: (args) ->
    args ?= {}

    for prop in [ "name", "body" ]
      args[prop] ?= @[prop]()

    args.source = @source()

    constructor = @constructor

    return new constructor args

  attachToMeta: (meta) ->
    @_setAssociatedMeta meta
    return

  detachFromMeta: (meta) ->
    @_clearAssociatedMeta()
    return

  name: ->
    return @_name

  body: ->
    return @_body

  source: ->
    return @_source

  associatedMeta: ->
    return @_associatedMeta

  _setAssociatedMeta: (meta) ->
    @_associatedMeta = meta
    return

  _clearAssociatedMeta: ->
    delete @_associatedMeta
    return

module.exports = Method
