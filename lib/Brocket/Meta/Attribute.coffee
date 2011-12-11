_      = require "underscore"
Method = require "./Method"
util   = require "util"

class Attribute
  constructor: (args) ->
    @_name      = args.name
    @_slotName  = "  __#{ @_name }__  "

    @_access    = args.access    ? "ro"
    @._validateAccess @_access

    @_required  = args.required  ? false
    @_lazy      = args.lazy      ? false

    if args.accessor
      @_accessor = args.accessor
    else if @_access == "rw" && ! args.reader? && ! args.writer
      @_accessor = @_name

    if !@_accessor?
      if args.reader?
        @_reader = args.reader
      else if @_access == "ro"
        @_reader = @_name

      @_writer = args.writer if args.writer?

    @_predicate = args.predicate ? null
    @_clearer   = args.clearer   ? null

    @_methodClass = args.methodClass ? Method

    @_methods = {}

    @._setDefaultProperties args

    @._buildMethods()

    return

  _setDefaultProperties: (args) ->
    if Object.prototype.hasOwnProperty.call args, "default"
      def = args.default
      @_default = def
      @__defaultFunc = -> def
    else if Object.prototype.hasOwnProperty.call args, "builder"
      builder = args.builder
      @_builder = builder
      @__defaultFunc = (instance) -> instance[builder].call instance

    if @_lazy && !@__defaultFunc?
      throw "You must provide a default or builder for a lazy attribute"

    return

  _validateAccess: (access) ->
    return if access in [ "bare", "ro", "rw" ]
    throw "The access value for an attribute must be \"bare, \"ro\" or \"rw\", not \"#{access}\""

  _buildMethods: () ->
    name     = @.name()
    slotName = @.slotName()
    def      = @._defaultFunc()

    methods = @._methodsObj()
    mclass  = @.methodClass()

    if @.hasAccessor()
      if @.accessor() instanceof Method
        methods[ @.accessor().name() ] = @.accessor()
      else
        body =
          if @.isLazy()
            ->
              if arguments.length > 0
                this[slotName] = arguments[0]

              if ! Object.prototype.hasOwnProperty.call this, name
                this[slotName] = def.call this
              return this[slotName]
          else
            ->
              if arguments.length > 0
                this[slotName] = arguments[0]

              return this[slotName]

    if @.hasReader()
      if @.reader() instanceof Method
        methods[ @.reader().name() ] = @.reader()
      else
        body =
          if @.isLazy()
            ->
              if ! Object.prototype.hasOwnProperty.call this, name
                this[slotName] = def.call this
              return this[slotName]
          else
            ->
              return this[slotName]
        methods[ @.reader() ] = new mclass name: @.reader(), body: body

    if @.hasWriter()
      if @.writer() instanceof Method
        methods[ @.writer().name() ] = @.writer()
      else
        body = (value) ->
          this[slotName] = value
      methods[ @.writer() ] = new mclass name: @.writer(), body: body

    if @.hasClearer()
      body = -> delete this[slotName]
      methods[ @.clearer() ] = new mclass name: @.clearer(), body: body

    if @.hasPredicate()
      body = -> Object.prototype.hasOwnProperty.call this, slotName
      methods[ @.predicate() ] = new mclass name: @.predicate(), body: body

    return

  initializeInstanceSlot: (instance, params) ->
    name = @.name();

    if params? && typeof params == "object" && Object.prototype.hasOwnProperty.call params, name
      instance[ @.slotName() ] = params[name]
      return

    return if @.isLazy() || ! @._defaultFunc()

    instance[slotName] = @.defaultFunc().call instance

    return

  name: ->
    @_name

  slotName: ->
    @_slotName

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

  accessor: ->
    @_accessor

  hasAccessor: ->
    return @.accessor()?

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
    @__defaultFunc

module.exports = Attribute
