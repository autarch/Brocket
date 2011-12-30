test = (require "tap").test
util = require "util"

Brocket   = require "../../lib/Brocket"
Role      = require "../../lib/Brocket/Meta/Role"
RoleSugar = require "../../lib/Brocket/Role"

test "Role sugar", (t) ->
  FooRole = RoleSugar.makeRole "FooRole"

  t.ok FooRole instanceof Role, "makeRole returns a Role object"

  t.equivalent FooRole.attributes(), [], "role has no attributes"

  RoleSugar.makeRole "FooRole", (B) ->
    B.has "foo", access: "rw", default: 42

  t.ok (FooRole.hasAttribute "foo"), "added a foo attribute"
  fooAttr = FooRole.attributeNamed "foo"
  t.equal fooAttr.access(), "rw", "access is read-write"

  RoleSugar.makeRole "FooRole", (B) ->
    B.method "m1", -> return "m1"

  t.ok (FooRole.hasMethod "m1"), "foo has m1 method"

  called = false
  BarRole = RoleSugar.makeRole "BarRole", (B) ->
    B.with FooRole
    B.has "bar", builder: "_buildBar"
    B.method "_buildBar", -> 84
    B.method "m2", -> "m2"

    B.has "lazy", builder: "_buildLazy", lazy: true
    B.method "_buildLazy", ->
      called = true
      return 99

  t.ok (BarRole.doesRole FooRole), "BarRole does FooRole"

  MyClass = Brocket.makeClass "MyClass", (B) ->
    B.with BarRole

  myMeta = MyClass.meta()
  t.ok (myMeta.doesRole BarRole), "MyClass does BarRole"
  t.ok (myMeta.doesRole FooRole), "MyClass does FooRole"

  myObj = new MyClass
  t.equal myObj.m1(), "m1", "BarRole composes m1 method"
  t.equal myObj.m2(), "m2", "BarRole composes m2 method"
  t.equal myObj.bar(), 84, "bar method gets default from builder"
  t.ok !called, "builder for lazy attribute has not been called yet"
  t.equal myObj.lazy(), 99, "lazy attr defaults to 99"
  t.ok called, "builder for lazy attribute has was called"

  t.end()
