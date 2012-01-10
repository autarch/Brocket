test = (require "tap").test
util = require "util"

Brocket = require "../lib/Brocket"
Cache   = require "../lib/Brocket/Meta/Cache"

test "BUILD methods", (t) ->
  Cache._clearMetaObjects()

  build = []

  Foo = Brocket.makeClass "Foo", (B) ->
    B.method "BUILD", ->
      build.push "Foo"

  foo = new Foo
  t.equivalent build, ["Foo"], "BUILD is called for Foo"

  Bar = Brocket.makeClass "Bar", (B) ->
    B.subclasses Foo
    B.method "BUILD", ->
      build.push "Bar"

  build = []
  bar = new Bar
  t.equivalent build, ["Foo", "Bar"], "BUILD is called for Foo and Bar (from parent to child)"

  Baz = Brocket.makeClass "Baz", (B) ->
    B.subclasses Foo

  Buz = Brocket.makeClass "Buz", (B) ->
    B.subclasses Baz
    B.method "BUILD", ->
      build.push "Buz"

  build = []
  buz = new Buz
  t.equivalent build, ["Foo", "Buz"], "BUILD is called for Foo and Buz (from parent to child, and can skip a generation)"

  t.end()

test "BUILDARGS", (t) ->
  Cache._clearMetaObjects()

  Foo = Brocket.makeClass "Foo", (B) ->
    B.has "name"
    B.method "BUILDARGS", (args) ->
      if typeof args == "string"
        return { name: args }
      else
        return @_super args

  foo1 = new Foo name: "foo1"
  t.equal foo1.name(), "foo1", "got name from object passed to constructor"

  foo2 = new Foo "foo2"
  t.equal foo2.name(), "foo2", "got name from string passed to constructor"

  t.end()

