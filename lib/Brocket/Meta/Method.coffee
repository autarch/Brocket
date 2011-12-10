class Method
  constructor: (args) ->
    @_name   = args.name
    @_body   = args.body
    @_source = args.source
    @_associatedClass = args.metaclass

  clone: ->
    constructor = @.constructor
    return new constructor name: @.name(), body: @.body(), source: @.source()

  attachToClass: (metaclass) ->
    @.associatedClass metaclass

  detachFromClass: (metaclass) ->
    @._clearAssociatedClass()

  name: ->
    @_name

  body: ->
    @_body

  source: (source) ->
    @_source = source if source?
    return @_source

  associatedClass: (metaclass) ->
    @_associatedClass = metaclass if metaclass?
    return @_metaclass

  _clearAssociatedClass: ->
    delete @_associatedClass

module.exports = Method
