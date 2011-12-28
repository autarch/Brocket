test = (require "tap").test
util = require "util"

Base      = require "../../lib/Brocket/Base"
Brocket   = require "../../lib/Brocket"
Class     = require "../../lib/Brocket/Meta/Class"
RoleSugar = require "../../lib/Brocket/Role"

test "Brocket sugar", (t) ->
  Foo = Brocket.makeClass "Foo";
  fooMeta = Foo.meta()

  t.type Foo, "function", "makeClass returns a function"
  t.ok fooMeta instanceof Class, "fooMeta returns a fooMeta"
  t.equivalent fooMeta.superclasses(), [ Base.meta() ], "superclasses is Base"

  t.equivalent fooMeta.attributes(), [], "class has no attributes"
  for name in [ "BUILDARGS", "BUILDALL" ]
    t.ok (fooMeta.hasMethod name), "class has #{name} method"

  Brocket.makeClass "Foo", (B) ->
    B.has "foo", access: "rw", default: 42

  t.ok (fooMeta.hasAttribute "foo"), "added a foo attribute"
  fooAttr = fooMeta.attributeNamed "foo"
  t.equal fooAttr.access(), "rw", "access is read-write"
  t.ok (fooMeta.hasMethod "foo"), "foo attribute created a foo method"

  Brocket.makeClass "Foo", (B) ->
    B.method "m1", -> return "m1"

  Foo.prototype.m2 = -> return "m2"

  t.ok (fooMeta.hasMethod "m1"), "foo has m1 method"
  t.ok (fooMeta.hasMethod "m2"), "foo has m2 method"

  fooObj = new Foo

  t.equal fooObj.meta(), Foo.meta(), "can call meta() on object and class"
  t.equal fooObj.m1(), "m1", "m1 method returns expected value"
  t.equal fooObj.m2(), "m2", "m2 method returns expected value"
  t.equal fooObj.foo(), 42, "foo accessor returns default value"

  called = false
  Bar = Brocket.makeClass "Bar", (B) ->
    B.has "bar", builder: "_buildBar"
    B.method "_buildBar", -> 84
    B.subclasses Foo

    B.has "lazy", builder: "_buildLazy", lazy: true
    B.method "_buildLazy", ->
      called = true
      return 99

  barMeta = Bar.meta()

  t.equivalent barMeta.superclasses(), [ fooMeta ], "subclasses sets superclasses as expected"

  barObj = new Bar
  t.equal barObj.m1(), "m1", "Bar class inherits m1 method"
  t.equal barObj.m2(), "m2", "Bar class inherits m2 method"
  t.equal barObj.bar(), 84, "bar method gets default from builder"
  t.ok !called, "builder for lazy attribute has not been called yet"
  t.equal barObj.lazy(), 99, "lazy attr defaults to 99"
  t.ok called, "builder for lazy attribute has was called"

  MyRole = RoleSugar.makeRole "MyRole", (B) ->
    B.has "size"
    B.method "color", -> "blue"

  Baz = Brocket.makeClass "Baz", (B) ->
    B.with MyRole
    B.has "level"
    B.method "quality", ->
      if @color() == "blue"
        return "high"
      else
        return "low"

  bazObj = new Baz size: 5, level: 42
  t.equal bazObj.size(), 5, "size returns value passed to constructor"
  t.equal bazObj.level(), 42, "level returns value passed to constructor"
  t.equal bazObj.quality(), "high", "quality calls method from role"
  t.ok (bazObj.meta().doesRole MyRole), "baz object does MyRole"

  t.end()
