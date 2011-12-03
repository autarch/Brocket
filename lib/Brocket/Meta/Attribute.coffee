Method = require "./Method"
_      = require "underscore"
util   = require "util"

class Attribute
  constructor: (args) ->
    @_name      = args.name
    @_access    = args.access    ? "ro"
    @._validateAccess @_access

    @_required  = args.required  ? false
    @_lazy      = args.lazy      ? false

    if args.reader?
      @_reader = args.reader
    else if @_access != "bare"
      @_reader = @_name

    @_writer    = do ->
      if args.writer?
        args.writer
      else if @_access == "rw"
        @_name

    @_predicate = args.predicate ? null
    @_clearer   = args.clearer   ? null

    @_methodClass = args.methodClass ? Method

    @_methods = {}

    if Object.prototype.hasOwnProperty args, "default"
      def = args.default
      @_default = def
      @_defaultFunc = -> def
    else if Object.prototype.hasOwnProperty args, "builder"
      builder = args.builder
      @_builder = builder
      @_defaultFunc = -> (instance) instance[builder].call instance

    if @_lazy && ! @_defaultFunc?
      throw "You must provide a default or builder for lazy attributes"

    @._buildMethods()

    return

  _validateAccess: (access) ->
    return if access in [ "bare", "ro", "rw" ]
    throw 'The access value for an attribute must be "bare, "ro" or "rw", not "#{ access }"'

  _buildMethods: () ->
    name = @.name()
    def = @._defaultFunc()

    methods = {}

    if @.hasReader()
      methods[ @.reader() ] = do =>
        if @.isLazy()
          ->
            if ! Object.prototype.hasOwnProperty this, name
              this[name] = def.call this
            return this[name]
        else
          ->
            return this[name]

    if @.hasWriter()
      methods[ @.writer() ] = (value) ->
        this[name] = value

    if @.hasClearer()
      methods[ @.clearer() ] = ->
        delete this[name]

    if @.hasPredicate()
      methods[ @.predicate() ] = ->
        Object.prototype.hasOwnProperty.call this, name

    mclass = @.methodClass()
    for own name, method of methods
      @._methodsObj()[name] = new mclass name: name, body: method

    return

  initializeInstanceSlot: (instance, params) ->
    name = @.name();

    if Object.prototype.hasOwnProperty.call params, name
      instance[name] = params[name]
      return

    return if @.isLazy() || ! @._defaultFunc()

    instance[name] = @.defaultFunc().call instance

    return

  name: ->
    @_name

  access: ->
    @_access

  required: ->
    @_required

  isLazy: ->
    @_lazy

  reader: ->
    @_reader

  hasReader: ->
    @.reader()?

  writer: ->
    @_writer

  hasWriter: ->
    return @.writer()?

  predicate: ->
    @_predicate

  hasPredicate: ->
    @.predicate()?

  clearer: ->
    @_clearer

  hasClearer: ->
    @.clearer()?

  methodClass: ->
    @._methodClass

  _methodsObj: ->
    @_methods

  methods: ->
    _.values @._methodsObj()

  _defaultFunc: ->
    @defaultFunc

module.exports = Attribute
