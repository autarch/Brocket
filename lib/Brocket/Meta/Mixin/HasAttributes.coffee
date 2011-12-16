class HasAttributes
  _buildAttributeProperties: (args) ->
    @_attributes     = {}
    @_attributeClass = args.attributeClass ? @_defaultAttributeClass()

  addAttribute: (attribute) ->
    if attribute not instanceof @_defaultAttributeClass()
      aclass = @attributeClass()
      attribute = new aclass attribute

    @attributes()[ attribute.name() ] = attribute
    @addMethod method for method in attribute.methods()

    return attribute

  removeAttribute: (attribute) ->
    delete @attributes()[ attribute.name() ]
    @removeMethod method for method in attribute.methods()
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