`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define (require) ->
  _    = require "underscore"
  util = require "util"

  class HasAttributes
    _buildAttributeProperties: (args) ->
      @__attributeMap  = {}
      @_attributeClass = args.attributeClass ? @_defaultAttributeClass()

    addAttribute: (attribute) ->
      if attribute not instanceof @_defaultAttributeClass()
        aclass = @attributeClass()
        attribute = new aclass attribute

      @_attachAttribute attribute
      @_attributeMap()[ attribute.name() ] = attribute

      return attribute

    removeAttribute: (attribute) ->
      @_detachAttribute attribute
      delete @_attributeMap()[ attribute.name() ]
      return

    hasAttribute: (name) ->
      return @_attributeMap()[name]?

    attributeNamed: (name) ->
      return @_attributeMap()[name]

    attributes: ->
      return _.values @_attributeMap()

    _attributeMap: ->
      return @__attributeMap

    attributeClass: ->
      return @_attributeClass
