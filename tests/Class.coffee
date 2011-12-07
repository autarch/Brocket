test = (require "tap").test
util = require "util"

Attribute = require "../lib/Brocket/Meta/Attribute";
Base      = (require "../lib/Brocket/Base")
Class     = (require "../lib/Brocket/Meta/Class")
Method    = (require "../lib/Brocket/Meta/Method")

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

  has = metaclass.hasMethod "attr1"
  t.ok has, "has a method named attr1"

  method = metaclass.methodNamed "attr1"
  t.ok method, "methodNamed finds attr1 method"
  t.ok metaclass.class().prototype.attr1, "method is added to class prototype"

  metaclass.removeAttribute attr1
  has = metaclass.hasAttribute "attr1"
  t.ok !has, "removeAttribute removed attr1"
  t.ok !metaclass.class().prototype.attr, "method is removed from class prototype"

  has = metaclass.hasMethod "attr1"
  t.ok !has, "removeAttribute removed method named attr1"

  metaclass.class().prototype.foo = () ->
  method = metaclass.methodNamed "foo"
  t.ok method, "methodNamed finds foo method"
  t.ok method instanceof Method, "methodNamed always returns a Method object"

  t.end()