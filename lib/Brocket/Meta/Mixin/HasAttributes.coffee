_    = require "underscore"
util = require "util"

class HasAttributes
  _buildAttributeProperties: (args) ->
    @_attributes     = {}
    @_attributeClass = args.attributeClass ? @_defaultAttributeClass()

  addAttribute: (attribute) ->
    if attribute not instanceof @_defaultAttributeClass()
      aclass = @attributeClass()
      attribute = new aclass attribute

    @_attachAttribute attribute

    @attributes()[ attribute.name() ] = attribute

    return attribute

  removeAttribute: (attribute) ->
    @_detachAttribute attribute
    delete @attributes()[ attribute.name() ]
    return

  attribute: (name) ->
    return @attributes()[name]

  hasAttribute: (name) ->
    return @attribute(name)?

  attributes: ->
    @_attributes

  attributeClass: ->
    @_attributeClass

module.exports = HasAttributes