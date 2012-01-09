_    = require "underscore"
test = (require "tap").test
util = require "util"

Attribute      = require "../../lib/Brocket/Meta/Attribute";
Base           = require "../../lib/Brocket/Base"
Cache          = require "../../lib/Brocket/Meta/Cache"
Class          = require "../../lib/Brocket/Meta/Class"
Helpers        = require "../../lib/Brocket/Helpers"
Method         = require "../../lib/Brocket/Meta/Method"
RequiredMethod = require "../../lib/Brocket/Meta/Role/RequiredMethod"
Role           = require "../../lib/Brocket/Meta/Role"
RoleAttribute  = require "../../lib/Brocket/Meta/Role/Attribute"

test "role basics", (t) ->
  Cache._clearMetaObjects()
  role = new Role name: "MyRole"

  t.equal role.name(), "MyRole", "name returns MyRole"

  has = role.hasAttribute "attr1"
  t.ok !has, "no attribute named attr1"

  attr1 = null
  func = -> attr1 = role.addAttribute name: "attr1"
  t.doesNotThrow func, "no error thrown from addAttribute"

  t.type attr1, RoleAttribute, "addAttribute returns a role attribute"
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
  t.type method, Method, "role methods are Method instances"
  t.equal method.source(), role,
    "source() returns the role to which the method belongs"
  t.equal method.associatedMeta(), role,
    "associatedMeta() returns the role to which the method belongs"

  role.removeMethod "newMeth"
  t.ok (! role.hasMethod "newMeth"), "removeMethod removed the newMeth method"
  t.ok (! method.associatedMeta()), "no associatedMeta for method after it was removed from the class"

  role.addRequiredMethod "foo"
  role.addRequiredMethod (new RequiredMethod name: "bar")
  t.equivalent ( m.name() for m in role.requiredMethods() ), [ "foo", "bar" ],
    "required method list contains the expected values"

  t.end()

test "role metaobject cache", (t) ->
  Cache._clearMetaObjects()

  role1 = new Role name: "MyRole1"
  role1._arbitrary = 42

  role1Clone = new Role name: "MyRole1"

  t.equal role1, role1Clone, "two roles with the same name are the same object"
  t.equal role1Clone._arbitrary, 42, "really ensure that the two objects are the same"

  role1Also = new Role name: "MyRole1", cache: false
  t.ok role1 != role1Also, "can explicitly not cache a role"

  role2 = new Role name: "MyRole2", cache: false
  t.ok (!Cache.metaObjectExists "MyRole2"), "MyRole2 role is not in the meta object cache"

  Cache._clearMetaObjects()

  new Class name: "Clash"

  func = -> new Role name: "Clash"
  t.throws func, {
      name:    "Error",
      message: "Found an existing meta object named Clash which is not a Role object. You cannot create a Class and a Role with the same name.",
    },
    "got an error trying to create a Role with the same name as a Class"

  t.end()

test "role application to a class", (t) ->
  Cache._clearMetaObjects()

  role = new Role name: "MyRole"
  role.addAttribute name: "name", access: "ro"
  role.addAttribute name: "size", access: "rw"
  role.addAttribute name: "level", access: "rw"
  role.addMethod name: "foo", body: -> 42
  role.addMethod name: "bar", body: -> 84
  role.addMethod name: "ignored", body: -> 12
  role.addMethod name: "baz", body: -> return @bar()
  role.addMethod name: "quux", body: -> return @something()

  metaclass = new Class name: "MyClass"
  metaclass.setSuperclasses Base
  metaclass.addAttribute name: "level", access: "ro"
  metaclass.addAttribute name: "label"
  metaclass.addMethod name: "ignored", body: -> 13
  metaclass.addMethod name: "something", body: -> 14

  func = -> role.apply metaclass
  t.doesNotThrow func, "no error applying role to class"

  t.ok (metaclass.doesRole role), "class does the role (role provided as object)"
  t.ok (metaclass.doesRole "MyRole"), "class does the role (role provided as name)"

  for name in [ "name", "size", "level", "label" ]
    t.ok (metaclass.hasAttribute name), "class has an attribute named #{name}"

  for name in [ "foo", "bar", "ignored", "baz", "quux", "something" ]
    t.ok (metaclass.hasMethod name), "class has a method named #{name}"

  t.equal (metaclass.attributeNamed "level").access(), "ro",
    "level attribute in role does not override level attribute in class"

  t.equal metaclass.roleApplications().length, 1, "class has one role application object"
  t.equivalent metaclass.roles(), [role], "roles() returns list of roles for the class"

  MyClass = metaclass.class()
  obj = new MyClass name: "a name", size: 42

  t.ok obj, "MyClass constructor returns something"
  t.equal obj.name(), "a name", "can call name() method on an object of MyClass"
  t.equal obj.ignored(), 13, "ignored() calls class method, not role method"
  t.equal obj.quux(), 14, "method from role can call method from class"

  t.end()

test "role application to a role", (t) ->
  Cache._clearMetaObjects()

  roleA = new Role name: "MyRoleA"
  roleA.addAttribute name: "name", access: "ro"
  roleA.addAttribute name: "size", access: "rw"
  roleA.addAttribute name: "level", access: "rw"
  roleA.addMethod name: "foo", body: -> 42
  roleA.addMethod name: "bar", body: -> 84
  roleA.addMethod name: "consumerWins", body: -> 13
  roleA.addMethod name: "baz", body: -> return @bar()
  roleA.addMethod name: "quux", body: -> return @something()

  roleB = new Role name: "MyRoleB"
  roleB.addAttribute name: "level", access: "ro"
  roleB.addAttribute name: "label"
  roleB.addMethod name: "consumerWins", body: -> "x"
  roleB.addMethod name: "something", body: -> 14

  func = -> roleA.apply roleB
  t.doesNotThrow func, "no error applying MyRoleA to MyRoleB"

  t.ok (roleB.hasAttribute "name"), "MyRoleB has a name attribute"
  t.ok (roleB.hasMethod "foo"), "MyRoleB has a foo attribute"

  metaclass = new Class name: "MyClass"
  func = -> roleB.apply metaclass
  t.doesNotThrow func, "can apply MyRoleB to a class"

  MyClass = metaclass.class()
  obj = new MyClass
  t.equal obj.consumerWins(), "x", "no conflict with method of same name when one role consumes another - consumer wins"

  t.end()

test "role summation", (t) ->
  Cache._clearMetaObjects()
  roleA = new Role name: "RoleA"
  roleA.addMethod name: "foo", body: -> 42
  roleA.addMethod name: "bar", body: -> 42

  roleB = new Role name: "RoleB"
  roleB.addMethod name: "baz", body: -> 42
  roleB.addMethod name: "buz", body: -> 42

  metaclass = new Class name: "MyClass1"
  Helpers.applyRoles metaclass, [ roleA, roleB ]

  for name in [ "foo", "bar", "baz", "buz" ]
    t.ok (metaclass.hasMethod name), "metaclass has #{name} method after consuming RoleA and RoleB"

  t.end()
