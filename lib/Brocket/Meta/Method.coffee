class Method
  constructor: (args) ->
    @name   = args.name
    @body   = args.body
    @source = args.source

  attachToClass: (metaclass) ->
    @.source metaclass

  detachFromClass: (metaclass) ->
    @.source null

  name: ->
    @name

  body: ->
    @body

  source: (source) ->
    @source = source if source?
    return @source

module.exports = Method
