_    = require "underscore"
test = (require "tap").test
util = require "util"

Attribute      = require "../../lib/Brocket/Meta/Attribute";
Base           = require "../../lib/Brocket/Base"
Cache          = require "../../lib/Brocket/Meta/Cache"
Class          = require "../../lib/Brocket/Meta/Class"
Method         = require "../../lib/Brocket/Meta/Method"
RequiredMethod = require "../../lib/Brocket/Meta/Role/RequiredMethod"
Role           = require "../../lib/Brocket/Meta/Role"
RoleAttribute  = require "../../lib/Brocket/Meta/Role/Attribute"

test "role basics", (t) ->
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
  role1 = new Role name: "MyRole3"
  role1._arbitrary = 42

  role2 = new Role name: "MyRole3"

  t.equal role1, role2, "two roles with the same name are the same object"
  t.equal role2._arbitrary, 42, "really ensure that the two objects are the same"

  role3 = new Role name: "MyRole3", cache: false

  t.ok role1 != role3, "can explicitly not cache a class"

  role4 = new Role name: "MyRole4", cache: false
  t.ok (!Cache.metaObjectExists "MyRole4"), "MyRole4 role is not in the meta object cache"

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
  role = new Role name: "MyRole5"
  role.addAttribute name: "name", access: "ro"
  role.addAttribute name: "size", access: "rw"
  role.addAttribute name: "level", access: "rw"
  role.addMethod name: "foo", body: -> 42
  role.addMethod name: "bar", body: -> 84
  role.addMethod name: "ignored", body: -> 12
  role.addMethod name: "baz", body: -> return @bar()
  role.addMethod name: "quux", body: -> return @something()

  metaclass = new Class name: "MyClass5"
  metaclass.setSuperclasses Base
  metaclass.addAttribute name: "level", access: "ro"
  metaclass.addAttribute name: "label"
  metaclass.addMethod name: "ignored", body: -> 13
  metaclass.addMethod name: "something", body: -> 14

  func = -> role.apply metaclass
  t.doesNotThrow func, "no error applying role to class"

  t.ok (metaclass.doesRole role), "class does the role (role provided as object)"
  t.ok (metaclass.doesRole "MyRole5"), "class does the role (role provided as name)"

  for name in [ "name", "size", "level", "label" ]
    t.ok (metaclass.hasAttribute name), "class has an attribute named #{name}"

  for name in [ "foo", "bar", "ignored", "baz", "quux", "something" ]
    t.ok (metaclass.hasMethod name), "class has a method named #{name}"

  t.equal (metaclass.attributeNamed "level").access(), "ro",
    "level attribute in role does not override level attribute in class"

  t.equal metaclass.roleApplications().length, 1, "class has one role application object"
  t.equivalent metaclass.roles(), [role], "roles() returns list of roles for the class"

  MyClass5 = metaclass.class()
  obj = new MyClass5 name: "a name", size: 42

  t.ok obj, "MyClass5 constructor returns something"
  t.equal obj.name(), "a name", "can call name() method on an object of MyClass5"
  t.equal obj.ignored(), 13, "ignored() calls class method, not role method"
  t.equal obj.quux(), 14, "method from role can call method from class"

  metaclass = new Class name: "MyClass6"
  role.apply metaclass, "-excludes": "foo"

  t.ok (metaclass.doesRole role), "MyClass6 does MyRole5"
  t.ok (! metaclass.hasMethod "foo"), "excluded method is not applied to the class"

  metaclass = new Class name: "MyClass7"
  role.apply metaclass, "-excludes": ["foo"]

  t.ok (metaclass.doesRole role), "MyClass7 does MyRole5"
  t.ok (! metaclass.hasMethod "foo"), "excluded method is not applied to the class"

  metaclass = new Class name: "MyClass8"
  role.apply metaclass, "-excludes": "foo", "-aliases": { foo: "foo2" }

  t.ok (metaclass.doesRole role), "MyClass8 does MyRole5"
  t.ok (! metaclass.hasMethod "foo"), "excluded method is not applied to the class"
  t.ok (metaclass.hasMethod "foo2"), "aliased method is applied to the class"

  metaclass = new Class name: "MyClass8"
  role.apply metaclass, "-aliases": { foo: "foo2" }

  t.ok (metaclass.doesRole role), "MyClass8 does MyRole5"
  t.ok (metaclass.hasMethod "foo"), "aliased method original name is applied to the class"
  t.ok (metaclass.hasMethod "foo2"), "aliased method is applied to the class"

  t.end()

test "role application to a role", (t) ->
  role6 = new Role name: "MyRole6"
  role6.addAttribute name: "name", access: "ro"
  role6.addAttribute name: "size", access: "rw"
  role6.addAttribute name: "level", access: "rw"
  role6.addMethod name: "foo", body: -> 42
  role6.addMethod name: "bar", body: -> 84
  role6.addMethod name: "consumerWins", body: -> 13
  role6.addMethod name: "baz", body: -> return @bar()
  role6.addMethod name: "quux", body: -> return @something()

  role7 = new Role name: "MyRole7"
  role7.addAttribute name: "level", access: "ro"
  role7.addAttribute name: "label"
  role7.addMethod name: "consumerWins", body: -> "x"
  role7.addMethod name: "something", body: -> 14

  func = -> role6.apply role7
  t.doesNotThrow func, "no error applying MyRole6 to MyRole7"

  t.ok (role7.hasAttribute "name"), "MyRole7 has a name attribute"
  t.ok (role7.hasMethod "foo"), "MyRole7 has a foo attribute"

  metaclass = new Class name: "MyClass9"
  func = -> role7.apply metaclass
  t.doesNotThrow func, "can apply MyRole7 to a class"

  MyClass9 = metaclass.class()
  obj = new MyClass9
  t.equal obj.consumerWins(), "x", "no conflict with method of same name when one role consumes another - consumer wins"

  t.end()