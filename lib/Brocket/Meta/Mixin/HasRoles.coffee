_    = require "underscore"
util = require "util"

Role = null

class HasRoles
  _buildRoleProperties: ->
    Role ?= require "../Role"

    @_localRoles = []
    @_roleApplications = []

  addRole: (role) ->
    @localRoles().push role
    return

  doesRole: (role) ->
    name =
     if role instanceof Role
        role.name()
      else
        role

    for role in @roles()
      return true if role.name() == name

    return false

  roles: ->
    roles = []

    seen = {}

    for meta in @_allRoleSources()
      for role in meta.localRoles()
        continue if seen[ role.name() ]
        seen[ role.name() ] = true
        roles.push role

    return roles

  localRoles: ->
    @_localRoles

  roleApplications: ->
    @_roleApplications

module.exports = HasRoles
