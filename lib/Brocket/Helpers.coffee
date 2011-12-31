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

  optList = module.exports.optList roles, { lhs: Role }

  if optList.length == 2
    role = optList[0]
    args = optList[1]

    role.apply applyTo, args
  else
    (Role.combine optList).apply applyTo

  return

module.exports.optList = (list, args) ->
  args ?= {}

  lhsTest =
    if args.lhs?
      (item) -> item instanceof args.lhs
    else
      (item) -> typeof item == "string"

  pairs = []
  for item in list
    if lhsTest item
      pairs.push [item]
    else if item instanceof Object
      pairs[-1].push item

  retVal = []
  for pair in pairs
    pair[1] ?= {}
    retVal = retVal.concat pair

  return retVal
