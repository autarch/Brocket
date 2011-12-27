_    = require "underscore"
util = require "util"

module.exports.arrayToObject = (array) ->
  obj = {}
  for elt in array
    obj[elt] = true

  return obj

module.exports.className = (klass) ->
  if matches = klass.toString().match( /function\s*(\w+)/ )
    return matches[1]
  else
    return null
