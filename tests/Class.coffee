test = (require "tap").test
util = require "util"

Class = (require "../lib/Brocket/Meta/Class")
Base = (require "../lib/Brocket/Base")

metaclass = new Class name: "MyClass"

test "metaclass", (t) ->
    t.equal metaclass.name(), "MyClass", "name returns MyClass"
    t.equivalent metaclass.superclasses(), [Base], "superclasses defaults to Base"
    t.end()