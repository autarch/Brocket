test = (require "tap").test
util = require "util"

Attribute = require "../lib/Brocket/Meta/Attribute";
Base      = (require "../lib/Brocket/Base")
Class     = (require "../lib/Brocket/Meta/Class")
Method    = (require "../lib/Brocket/Meta/Method")

test "metaclass basics", (t) ->
  metaclass = new Class name: "MyClass"

  t.equal metaclass.name(), "MyClass", "name returns MyClass"

  t.equivalent metaclass.superclasses(), [], "superclasses defaults to empty list"
  metaclass.setSuperclasses Base.meta()
  t.equivalent metaclass.superclasses(), [ Base.meta() ],
    "superclasses includes Base after setSuperclasses"

  metaclass.setSuperclasses Base
  t.equivalent metaclass.superclasses(), [ Base.meta() ],
    "setSuperclasses accepts a class object with a meta() method"

  t.equal metaclass.class().prototype["BUILDARGS"],
    Base.prototype.BUILDARGS,
    "instance has a BUILDARGS method from Base"

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

  metaclass.class().prototype.foo = ->
  method = metaclass.methodNamed "foo"
  t.ok method, "methodNamed finds foo method"
  t.ok method instanceof Method, "methodNamed always returns a Method object"

  t.equal metaclass.class().meta(), metaclass,
    "underlying class's meta() method returns metaclass object"

  class Foo

  metaclass = Class.newFromClass Foo
  t.equal metaclass.name(), "Foo", "newFromClass figured out class name correctly"

  func = ->
  metaclass = Class.newFromClass func
  t.equal metaclass.name(), "__Anon__", "newFromClass handles anon classes"

  t.end()

test "constructInstance", (t) ->
  metaclass = new Class name: "MyClass"
  metaclass.setSuperclasses Base.meta()

  metaclass.addAttribute name: "foo"
  metaclass.addAttribute name: "bar"

  klass = metaclass.class()
  instance = new klass

  t.ok instance, "constructInstance returns something"
  t.equal typeof instance, "object", ".. it is an object"
  t.ok instance instanceof metaclass.class(), "instance is of the right class"

  instance = new klass foo: 42
  t.ok instance, "constructInstance returns something when given params"
  t.equal instance.foo(), 42, "foo param is set to 42"

  metaclass.class().prototype.BUILDARGS = (params) ->
    params = @_super params
    params.bar = 42
    return params

  instance = new klass foo: 12
  t.ok instance, "constructInstance returns something when given params"
  t.equal instance.foo(), 12, "foo param is set to 12"
  t.equal instance.bar(), 42, "bar param is set to 42"

  t.end()

test "methodInheritance", (t) ->
  class Foo
    method: -> 42

  class Bar
    method: -> 84

  metaclass = Class.newFromClass Bar
  metaclass.setSuperclasses Foo
  t.equivalent metaclass.superclasses(), [ Foo.meta() ],
    "can set superclass with a class and it is turned into a metaclass"

  bar = new Bar
  t.equal bar.method(), 84, "methods from superclass do not overwrite class's own methods"

  t.end()
