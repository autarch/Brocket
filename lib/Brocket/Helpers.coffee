_    = require "underscore"
util = require "util"

module.exports.arrayToObject = (array) ->
  obj = {}
  for elt in array
    obj[elt] = true

  return obj
