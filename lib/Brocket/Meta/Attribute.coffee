_             = require "underscore"
AttributeCore = require "./Mixin/AttributeCore"
Method        = require "./Method"
util          = require "util"

class Attribute
  for own key of AttributeCore.prototype
    unless Object.prototype.hasOwnProperty Attribute.prototype, key
      Attribute.prototype[key] = AttributeCore.prototype[key]

  constructor: (args) ->
    @_buildAttributeCore args

    @_slotName  = "  __#{ @_name }__  "

    @_methodClass = args.methodClass ? Method

    @_methods = {}

    @_buildMethods()

    return

  _buildMethods: () ->
    name     = @name()
    slotName = @slotName()
    def      = @_defaultFunc()

    methods = @_methodsObj()
    mclass  = @methodClass()

    if @hasAccessor()
      if @accessor() instanceof Method
        methods[ @accessor().name() ] = @accessor()
      else
        body =
          if @isLazy()
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
        methods[ @accessor() ] = new mclass name: @accessor(), body: body

    if @hasReader()
      if @reader() instanceof Method
        methods[ @reader().name() ] = @reader()
      else
        body =
          if @isLazy()
            ->
              if ! Object.prototype.hasOwnProperty.call this, name
                this[slotName] = def.call this
              return this[slotName]
          else
            ->
              return this[slotName]
        methods[ @reader() ] = new mclass name: @reader(), body: body

    if @hasWriter()
      if @writer() instanceof Method
        methods[ @writer().name() ] = @writer()
      else
        body = (value) ->
          this[slotName] = value
      methods[ @writer() ] = new mclass name: @writer(), body: body

    if @hasClearer()
      body = -> delete this[slotName]
      methods[ @clearer() ] = new mclass name: @clearer(), body: body

    if @hasPredicate()
      body = -> Object.prototype.hasOwnProperty.call this, slotName
      methods[ @predicate() ] = new mclass name: @predicate(), body: body

    return

  initializeInstanceSlot: (instance, params) ->
    name = @name();

    if params? && typeof params == "object" && Object.prototype.hasOwnProperty.call params, name
      instance[ @slotName() ] = params[name]
      return

    return if @isLazy() || ! @_defaultFunc()

    instance[ @slotName() ] = @_defaultFunc().call instance

    return

  slotName: ->
    @_slotName

  methodClass: ->
    @_methodClass

  _methodsObj: ->
    @_methods

  methods: ->
    _.values @_methodsObj()

module.exports = Attribute
