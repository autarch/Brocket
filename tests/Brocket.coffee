test = (require "tap").test
util = require "util"

Base    = require "../lib/Brocket/Base"
Brocket = require "../lib/Brocket"
Class   = require "../lib/Brocket/Meta/Class"

test "Brocket sugar", (t) ->
  Foo = Brocket.makeClass("Foo");
  fooMeta = Foo.meta()

  t.equal typeof Foo, "function", "makeClass returns a function"
  t.equal typeof Foo.has, "function", "class has a has() function"
  t.ok fooMeta instanceof Class, "fooMeta returns a fooMeta"
  t.equivalent fooMeta.superclasses(), [ Base.meta() ], "superclasses is Base"

  t.equivalent fooMeta.attributes(), {}, "class has no attributes"
  for name in [ "BUILDARGS", "BUILDALL" ]
    t.ok (fooMeta.hasMethod name), "class has #{name} method"

  Foo.has "foo", access: "rw", default: 42

  t.ok (fooMeta.hasAttribute "foo"), "added a foo attribute"
  fooAttr = fooMeta.attribute "foo"
  t.equal fooAttr.access(), "rw", "access is read-write"
  t.ok (fooMeta.hasMethod "foo"), "foo attribute created a foo method"

  Foo.method "m1", -> return "m1"
  Foo.prototype.m2 = -> return "m2"

  t.ok (fooMeta.hasMethod "m1"), "foo has m1 method"
  t.ok (fooMeta.hasMethod "m2"), "foo has m2 method"

  fooObj = new Foo

  t.equal fooObj.m1(), "m1", "m1 method returns expected value"
  t.equal fooObj.m2(), "m2", "m2 method returns expected value"
  t.equal fooObj.foo(), 42, "foo accessor returns default value"

  Foo.finalize()
  for func in [ "has", "method", "subclasses", "consumes", "finalize" ]
    t.ok !Foo[func], "finalize removes the #{func} function from the class"

  Bar = Brocket.makeClass("Bar")
  Bar.has "bar", builder: "_buildBar"
  Bar.method "_buildBar", -> 84
  Bar.subclasses Foo

  called = false
  Bar.has "lazy", builder: "_buildLazy", lazy: true
  Bar.method "_buildLazy", ->
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

  # This is just testing an alternate compact syntax for class definition
  Baz =
    (->
      @has "baz", access: "ro"
      @subclasses "Baz"
      @method "m3", -> 100
      @method "m4", -> 101
      @
    ).call Brocket.makeClass "Baz"

  bazObj = new Baz
  t.equal bazObj.m3(), 100, "m3 method returns expected value"

  t.end()
