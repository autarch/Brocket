Base  = require "./Brocket/Base"
Class = require "./Brocket/Meta/Class"
util  = require "util"

_has = (meta, name, attr) ->
  clone = name: name
  for own key, val of attr
    clone[key] = val

  meta.addAttribute clone

_method = (meta, name, body) ->
  meta.addMethod name: name, body: body, source: meta

_subclasses = (meta, supers) ->
  meta.setSuperclasses supers

_consumes = (meta, name, options) ->

_finalize = (klass) ->
  delete klass["has"]
  delete klass["method"]
  delete klass["subclasses"]
  delete klass["consumes"]
  delete klass["finalize"]
  return

module.exports.makeClass = (name) ->
  metaclass = new Class name: name

  metaclass.setSuperclasses(Base)

  klass = metaclass.class()

  klass.has        = (name, attr)    -> _has metaclass, name, attr
  klass.method     = (name, body)    -> _method metaclass, name, body
  klass.subclasses = (supers)        -> _subclasses metaclass, supers
  klass.consumes   = (role, options) -> _consumes metaclass, role, options
  klass.finalize   =                 -> _finalize @

  return klass
