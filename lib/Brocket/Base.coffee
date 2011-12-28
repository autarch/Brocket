Class = require "./Meta/Class"
util  = require "util"

class Base
  constructor: ->
    throw new Error "Cannot construct a Brocket/Base object"

  BUILDARGS: (params) ->
    ###
    In the typical case, the params will be passed as an array from the
    default constructor - this will be a single element array where the first
    element is an object containing key/values for the constructor params
    ###
    if typeof params == "object" && params instanceof Array
      return params[0] ? {}
    else
      return params ? {}

  BUILDALL: (params) ->
    return

  DOES: (role) ->
    return @meta().doesRole role

  _meta = new Class { name: "Brocket.Base", _class: @ }
  @meta: -> _meta

module.exports = Base
