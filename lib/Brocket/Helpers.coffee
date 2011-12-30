_    = require "underscore"
util = require "util"

Role = null

module.exports.arrayToObject = (array) ->
  if typeof array == "string"
    obj = {}
    obj[array] = true
    return obj

  obj = {}
  for elt in array
    obj[elt] = true

  return obj

module.exports.className = (klass) ->
  if matches = klass.toString().match( /function\s*(\w+)/ )
    return matches[1]
  else
    return null

module.exports.applyRoles = (applyTo, roles...) ->
  Role ?= require "./Meta/Role"

  if roles[0] instanceof Array
    roles = roles[0]

  pairs = []
  for item in roles
    if item instanceof Role
      pairs.push [item]
    else if item instanceof Object
      pairs[-1].push item

  for pair in pairs
    pair[1] ?= {}

  if pairs.length == 1
    role = pairs[0][0]
    args = pairs[0][1]

    role.apply applyTo, args
  else
    (Role.combine pairs).apply applyTo

  return
