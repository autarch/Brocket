_    = require "underscore"
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

  t.equal attr1.associatedClass(), metaclass,
    "associatedClass for attribute is set when it is added"

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

  class MyOtherClass

  metaclass = Class.newFromClass MyOtherClass
  t.equal metaclass.name(), "MyOtherClass", "newFromClass figured out class name correctly"

  func = ->
  metaclass = Class.newFromClass func
  t.equal metaclass.name(), "__Anon__", "newFromClass handles anon classes"

  t.end()

test "constructInstance", (t) ->
  metaclass = new Class name: "MyClass2"
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

  t.ok Foo.meta, "Foo class now has a meta method"
  t.equivalent metaclass.superclasses(), [ Foo.meta() ],
    "can set superclass with a class and it is turned into a metaclass"

  t.equivalent metaclass.linearizedInheritance(), [ Foo.meta() ],
    "linearizedInheritance returns all ancestors"

  bar = new Bar
  t.equal bar.method(), 84, "methods from superclass do not overwrite class's own methods"

  class Foo1
    x: ->

  class Foo2
    method: -> return @_super()
    bad:    -> return @_super()

  foo1meta = Class.newFromClass Foo1
  foo1meta.setSuperclasses Foo

  foo2meta = Class.newFromClass Foo2
  foo2meta.setSuperclasses Foo1;

  foo2 = new Foo2
  t.equal foo2.method(), 42, "methods can be inherited from grandparent classes"

  error
  try
    foo2.bad()
  catch e
    error = e

  t.ok error?, "error thrown from bad call to _super"

  if error?
    t.equal error.message,
      "No bad method found in any superclasses of Foo2 - superclasses are Foo1, Foo",
      "attempting to call _super when no superclass has the requested method fails"

  t.end()

test "metaclass cache", (t) ->
  metaclass1 = new Class name: "MyClass3"
  metaclass1._arbitrary = 42

  metaclass2 = new Class name: "MyClass3"

  t.equal metaclass1, metaclass2, "two metaclasses with the same name are the same object"
  t.equal metaclass2._arbitrary, 42, "really ensure that the two objects are the same"

  metaclass3 = new Class name: "MyClass3", cache: false

  t.ok metaclass1 != metaclass3, "can explicitly not cache a class"

  metaclass4 = new Class name: "MyClass4", cache: false
  t.ok (!Class.metaclassExists "MyClass4"), "MyClass4 metaclass is not in the metaclass cache"

  Class._clearMetaclasses()

  anon = ->
  anonmeta = Class.newFromClass anon

  t.equal anonmeta.name(), "__Anon__", "anon class name is __Anon__"
  t.equivalent Class.allMetaclasses(), [], "anon class is not cached"

  t.end()

