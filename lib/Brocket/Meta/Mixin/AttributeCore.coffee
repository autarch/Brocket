class AttributeCore
  _buildAttributeCore: (args) ->
    @_name = args.name

    @_access = args.access ? "ro"
    @_validateAccess @_access

    @_required  = args.required ? false
    @_lazy      = args.lazy     ? false

    @_setAccessorMethodProperties args

    @_setDefaultProperties args

  _validateAccess: (access) ->
    return if access in [ "bare", "ro", "rw" ]
    throw "The access value for an attribute must be \"bare, \"ro\" or \"rw\", not \"#{access}\""

  _setAccessorMethodProperties: (args) ->
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

    return

  _setDefaultProperties: (args) ->
    if Object.prototype.hasOwnProperty.call args, "default"
      def = args.default
      @_default = def
      @__defaultFunc = -> def
    else if Object.prototype.hasOwnProperty.call args, "builder"
      builder = args.builder
      @_builder = builder
      # XXX - need some sort of error handling
      @__defaultFunc = (instance) -> @[builder].call instance

    if @_lazy && !@__defaultFunc?
      throw "You must provide a default or builder for a lazy attribute"

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
    @reader()?

  writer: ->
    @_writer

  hasWriter: ->
    return @writer()?

  accessor: ->
    @_accessor

  hasAccessor: ->
    return @accessor()?

  predicate: ->
    @_predicate

  hasPredicate: ->
    @predicate()?

  clearer: ->
    @_clearer

  hasClearer: ->
    @clearer()?

  _defaultFunc: ->
    @__defaultFunc

module.exports = AttributeCore
