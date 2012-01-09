_           = require "underscore"
Application = require "../Application"
Helpers     = require "../../../Helpers"
util        = require "util"

class RoleSummation extends Application
  constructor: (args) ->
    @_roleParams = args.roleParams
    return

  _normalizeRoleParams: ->
    rp = @roleParams()

    for role in @compositeRole().roles()
      name = role.name()

      rp[name] ?= {}
      rp[name]["-alias"] ?= {}
      rp[name]["-excludes"] =
        if rp[name]["-excludes"]?
          Helpers.arrayToObject rp[name]["-excludes"]
        else
          {}

    return

  apply: (compositeRole) ->
    @_compositeRole = compositeRole
    @_normalizeRoleParams()
    super

  _checkRequiredMethods: ->
    roles = @compositeRole().roles()

    allRequired = []
    for role in roles
      for m in role.requiredMethods()
        continue if @hasAliasNamed m.name()
        continue if _.any( roles, (r) -> r.hasMethod m.name() )
        allRequired.push m

    for m in allRequired
      @compositeRole().addRequiredMethod m

    return

  _applyAttributes: ->
    allAttributes = []
    for role in @compositeRole().roles()
      allAttributes = allAttributes.concat role.attributes()

    seen = {}
    for attr in allAttributes
      name = attr.name()

      if seen[name]
        role1 = attr.associatedRole().name()
        role2 = seen[name].name()

        message = "We have encountered an attribute conflict with '#{name}'" +
                  " during role composition." +
                  " This attribute is defined in both #{role1} and #{role2}. " +
                  " This is a fatal error and cannot be disambiguated."
        throw new Error message

      seen[ attr.name() ] = attr

    for attr in allAttributes
      @compositeRole().addAttribute attr.clone()

    return

  _applyMethods: ->
    roles = @compositeRole().roles()
    allMethods = []

    for role in roles
      roleName = role.name()

      for method in role.methods()
        aliasedTo = @_methodAliasForRole roleName, method.name()
        if aliasedTo?
          allMethods.push { role: role, name: aliasedTo, method: method }

        continue if @_methodIsExcludedForRole roleName, method.name()

        allMethods.push { role: role, name: method.name(), method: method }

    seen = {}
    conflicts = {}
    methodMap = {}

    for method in allMethods
      continue if conflicts[ method.name ]

      saw = seen[ method.name ]
      if saw?
        if saw.method.body().toString() != method.method.body().toString()
          @compositeRole().addConflictingMethod method.name
          delete methodMap[ method.name ]
          conflicts[ method.name ] = true
          continue

      methodMap[ method.name ] = method.method

    for name, method of methodMap
      @compositeRole().addMethod method.clone name: name

    return

  hasAliasNamed: (name) ->
    return _.any @compositeRole().roles(), (r) -> r.aliasForMethod name

  _methodIsExcludedForRole: (role, name) ->
    return @roleParams()[role]["-excludes"][name]?

  _methodAliasForRole: (role, name) ->
    return @roleParams()[role]["-alias"][name]

  roleParams: ->
    @_roleParams

  compositeRole: ->
    @_compositeRole

module.exports = RoleSummation
