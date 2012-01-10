test = (require "tap").test
util = require "util"

Brocket = require "../lib/Brocket"

test "BUILD methods", (t) ->
  build = []

  Foo = Brocket.makeClass "Foo", (B) ->
    B.method "BUILD", ->
      build.push "Foo"

  foo = new Foo
  t.equivalent build, ["Foo"], "BUILD is called for Foo"

  build = []

  Bar = Brocket.makeClass "Bar", (B) ->
    B.subclasses Foo
    B.method "BUILD", ->
      build.push "Bar"

  bar = new Bar
  t.equivalent build, ["Foo", "Bar"], "BUILD is called for Foo and Bar (from parent to child)"

  t.end()

