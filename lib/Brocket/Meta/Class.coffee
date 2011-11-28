Base = require "../Base"

class Class
    constructor: (args) ->
        @_name = args.name
        throw "You must provide a name when constructing a class" unless @_name

        @_attributes   = {}
        @_methods      = {}
        @_superclasses = []

        @.setSuperclasses [Base]

        @_class = (params...) ->
            this.meta.constructInstance params
        @_class.meta = @

    setSuperclasses: (supers) ->
        @_superclasses = supers
        @._checkMetaclassCompatibility

    addAttribute: (attribute) ->
        @.attributes[ attribute.name() ] = attribute
        @.addMethod method for method in attribute.methods()
        return

    removeAttribute: (attribute) ->
        delete @.attributes[ attribute.name() ]
        @.removeMethod method for method in attribute.methods()
        return

    hasAttribute: (name) ->
        return @.attributes()[name]?

    addMethod: (method) ->
        @.methods()[ method.name() ] = method
        method.attachToClass this
        @.class()[ method.name() ] = method.body()
        return

    removeMethod: (method) ->
        delete @.methods()[ method.name() ]
        method.detachFromClass this
        delete @.class()[ method.name() ]
        return

    hasMethod: (name) ->
        return @.methods()[name]?

    _checkMetaclassCompatibility: (klass) ->
        return

    constructInstance: (params) ->
        params = this.class().BUILDARGS params

        instance = new this.class()
        for own name, attr of @.attributes()
            attr.initializeInstanceSlot instance params
        return instance

    name: ->
        @_name

    superclasses: ->
        @_superclasses

    attributes: ->
        @_attributes

    methods: ->
        @_methods

    class: ->
        @_class

module.exports = Class
