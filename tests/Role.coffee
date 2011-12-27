_    = require "underscore"
test = (require "tap").test
util = require "util"

Attribute     = require "../lib/Brocket/Meta/Attribute";
Base          = require "../lib/Brocket/Base"
Class         = require "../lib/Brocket/Meta/Class"
Method        = require "../lib/Brocket/Meta/Method"
Role          = require "../lib/Brocket/Meta/Role"
RoleAttribute = require "../lib/Brocket/Meta/Role/Attribute"

test "role basics", (t) ->
  role = new Role name: "MyRole"

  t.equal role.name(), "MyRole", "name returns MyRole"

  has = role.hasAttribute "attr1"
  t.ok !has, "no attribute named attr1"

  try
    attr1 = role.addAttribute name: "attr1"
    t.type attr1, RoleAttribute, "addAttribute returns a role attribute"
  catch error
    t.equal error, null, "no error thrown from addAttribute"

  t.equal attr1.associatedRole(), role,
    "associatedRole for attribute is set when it is added"

  has = role.hasAttribute "attr1"
  t.ok has, "has an attribute named attr1"

  role.removeAttribute attr1
  has = role.hasAttribute "attr1"
  t.ok !has, "removeAttribute removed attr1"

  role.addMethod {
    name: "newMeth",
    body: -> 99
  }
  t.ok (role.hasMethod "newMeth"), "addMethod added the newMeth method"

  method = role.methodNamed "newMeth"
  t.equal method.source(), role,
    "source() returns the role to which the method belongs"
  t.equal method.associatedMeta(), role,
    "associatedMeta() returns the role to which the method belongs"

  role.removeMethod "newMeth"
  t.ok (! role.hasMethod "newMeth"), "removeMethod removed the newMeth method"
  t.ok (! method.associatedMeta()), "no associatedMeta for method after it was removed from the class"

  t.end()