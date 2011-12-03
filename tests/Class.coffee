test = (require "tap").test
util = require "util"

Attribute = require "../lib/Brocket/Meta/Attribute";
Base      = (require "../lib/Brocket/Base")
Class     = (require "../lib/Brocket/Meta/Class")

metaclass = new Class name: "MyClass"

test "metaclass basics", (t) ->
  t.equal metaclass.name(), "MyClass", "name returns MyClass"

  t.equivalent metaclass.superclasses(), [Base], "superclasses defaults to Base"
  metaclass.setSuperclasses([])
  t.equivalent metaclass.superclasses(), [], "superclasses set to empty list"

  has = metaclass.hasAttribute "attr1"
  t.ok !has, "no attribute named attr1"

  try
    attr1 = metaclass.addAttribute name: "attr1"
    t.type attr1, Attribute, "addAttribute returns an attribute"
  catch error
    t.equal error, null, "no error thrown from addAttribute"

  has = metaclass.hasAttribute "attr1"
  t.ok has, "has an attribute named attr1"

  t.end()