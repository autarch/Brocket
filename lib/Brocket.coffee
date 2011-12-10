Base  = require "./Brocket/Base"
Class = require "./Brocket/Meta/Class"
util  = require "util"

has = (name, attr) ->

subclasses = (name, options) ->

consumes = (name, options) ->

finalize = ->
  delete @["has"]
  delete @["subclasses"]
  delete @["consumes"]
  return

module.exports.makeClass = (name) ->
  metaclass = new Class name: name

  metaclass.setSuperclasses(Base)

  klass = metaclass.class()

  klass.has        = has
  klass.subclasses = subclasses
  klass.consumes   = consumes
  klass.finalize   = finalize

  return klass
