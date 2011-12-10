class Method
  constructor: (args) ->
    @_name   = args.name
    @_body   = args.body
    @_source = args.source

  attachToClass: (metaclass) ->
    @.source metaclass

  detachFromClass: (metaclass) ->
    @._clearSource()

  name: ->
    @_name

  body: ->
    @_body

  source: (source) ->
    @_source = source if source?
    return @_source

  _clearSource: ->
    delete @_source

module.exports = Method
