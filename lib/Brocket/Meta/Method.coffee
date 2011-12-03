class Method
  constructor: (args) ->
    @_name   = args.name
    @_body   = args.body
    @_source = args.source

  attachToClass: (metaclass) ->
    @.source metaclass

  detachFromClass: (metaclass) ->
    @.source null

  name: ->
    @_name

  body: ->
    @_body

  source: (source) ->
    @_source = source if source?
    return @_source

module.exports = Method
