Method = require "./Method"

class Attribute
  constructor: (args) ->
    @name      = args.name
    @access    = args.access    ? "ro"
    @._validateAccess @access

    @required  = args.required  ? false
    @lazy      = args.lazy      ? false

    @reader    = args.reader    ? @name
    @writer    = do ->
      if args.writer?
        args.writer
      else if @access == "rw"
        @name

    @predicate = args.predicate ? false
    @clearer   = args.clearer   ? false

    if Object.prototype.hasOwnProperty args, "default"
      def = args.default
      @default = def
      @defaultFunc = -> def
    else if Object.prototype.hasOwnProperty args, "builder"
      builder = args.builder
      @builder = builder
      @defaultFunc = -> (instance) instance[builder].call instance

    if @lazy? && ! @defaultFunc?
      throw "You must provide a default or builder for lazy attributes"

    @._buildMethods

  _validateAccess: (access) ->
    return if access in [ "ro", "rw" ]
    throw "The access value for an attribute must be 'ro' or 'rw', not '#{ access }'"

  _buildMethods: (attr) ->
    attr.methods = {};
    name = attr.name
    def = @._defaultFunc()

    attr.methods[ attr.reader ] = do ->
      if attr.lazy?
        ->
          if ! Object.prototype.hasOwnProperty this name
            this[name] = def.call this
          return this[name]
      else
        ->
          return this[name]

    if attr.writer?
      attr.methods[ attr.writer ] = (value) ->
        this[name] = value

    if attr.clearer?
      attr.methods[ attr.clearer ] = ->
        delete this[name]

    if attr.predicate?
      attr.methods[ attr.predicate ] = ->
        Object.prototype.hasOwnProperty.call this name

    for own name, method in attr.methods
      attr.methods[name] = new Method name: name, body: method

    return

  initializeInstanceSlot: (instance, params) ->
    name = @.name();

    if Object.prototype.hasOwnProperty.call params name
      instance[name] = params[name]
      return

    return if @.isLazy() || ! @._defaultFunc()

    instance[name] = @.defaultFunc().call instance

    return

  name: ->
    @name

  isLazy: ->
    @lazy

  methods: ->
    @methods

  _defaultFunc: ->
    @defaultFunc

module.exports = Attribute
