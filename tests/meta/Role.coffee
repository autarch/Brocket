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
  t.equivalent (_.map role.requiredMethods(), (m) -> m.name()), [ "foo", "bar" ],
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

  role = new Class name: "Clash"

  try
    new Role name: "Clash"
  catch e
    error = e

  t.ok error?, "got an error trying to create a Role with the same name as a Class"
  t.equal error.message,
    "Found an existing meta object named Clash which is not a Role object. You cannot create a Class and a Role with the same name.",
    "error contains expected message"

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

  klass = new Class name: "MyClass"
  klass.setSuperclasses Base
  klass.addAttribute name: "level", access: "ro"
  klass.addAttribute name: "label"
  klass.addMethod name: "ignored", body: -> 13
  klass.addMethod name: "something", body: -> 14

  try
    role.applyRole klass
  catch e
    error = e

  t.ok !error?, "no error applying role to class"
  t.ok (klass.doesRole role), "class does the role (role provided as object)"
  t.ok (klass.doesRole "MyRole5"), "class does the role (role provided as name)"

  for name in [ "name", "size", "level", "label" ]
    t.ok (klass.hasAttribute name), "class has an attribute named #{name}"

  for name in [ "foo", "bar", "ignored", "baz", "quux", "something" ]
    t.ok (klass.hasMethod name), "class has a method named #{name}"

  t.equal (klass.attributeNamed "level").access(), "ro",
    "level attribute in role does not override level attribute in class"

  t.equal klass.roleApplications().length, 1, "class has one role application object"
  t.equivalent klass.roles(), [role], "roles() returns list of roles for the class"

  MyClass5 = klass.class()
  obj = new MyClass5 name: "a name", size: 42

  t.ok obj, "MyClass5 constructor returns something"
  t.equal obj.name(), "a name", "can call name() method on an object of MyClass5"
  t.equal obj.ignored(), 13, "ignored() calls class method, not role method"
  t.equal obj.quux(), 14, "method from role can call method from class"

  t.end()

