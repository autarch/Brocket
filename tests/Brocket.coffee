test = (require "tap").test
util = require "util"

Base    = require("../lib/Brocket/Base");
Brocket = require("../lib/Brocket");
Class   = require("../lib/Brocket/Meta/Class");

test "Brocket sugar", (t) ->
  Foo = Brocket.makeClass("Foo");

  t.equal typeof Foo, "function", "makeClass returns a function"
  t.equal typeof Foo.has, "function", "class has a has() function"
  t.ok Foo.meta() instanceof Class, "Foo.meta() returns a metaclass"
  t.equivalent Foo.meta().superclasses(), [ Base.meta() ], "superclasses is Base"

  t.equivalent Foo.meta().attributes(), {}, "class has no attributes"
  for name in [ "BUILDARGS", "BUILDALL" ]
    t.ok (Foo.meta().hasMethod name), "class has #{name} method"

  t.end()
