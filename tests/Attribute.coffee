test = (require "tap").test
_    = require "underscore"
util = require "util"

Attribute = require "../lib/Brocket/Meta/Attribute";
Base      = require "../lib/Brocket/Base"
Class     = require "../lib/Brocket/Meta/Class"
Method    = require "../lib/Brocket/Meta/Method"

test "attribute basics", (t) ->
  attr1 = new Attribute name: "foo"
  t.equal attr1.name(), "foo", "name() returns expected value"
  t.equal attr1.access(), "ro", "access() defaults to ro"
  t.equal attr1.required(), false, "required() defaults to false"
  t.equal attr1.isLazy(), false, "isLazy() defaults to false"
  t.equal attr1.reader(), "foo", "reader() defaults to attr name"
  t.ok ! attr1.hasAccessor(), "attr1 has no accessor"
  t.ok ! attr1.hasWriter(), "attr1 has no writer"
  t.ok ! attr1.hasPredicate(), "attr1 has no predicate"
  t.ok ! attr1.hasClearer(), "attr1 has no clearer"

  names = _.map attr1.methods(), (method) -> method.name()
  t.equivalent names, ["foo"], "methods returns a single method named foo"

  attr2 = new Attribute name: "foo", predicate: "hasFoo"
  names = _.map attr2.methods(), (method) -> method.name()
  t.equivalent names.sort(), ["foo", "hasFoo"], "methods includes reader and predicate"

  attr3 = new Attribute name: "foo", clearer: "clearFoo"
  names = _.map attr3.methods(), (method) -> method.name()
  t.equivalent names.sort(), ["clearFoo", "foo"], "methods includes reader and clearer"

  attr4 = new Attribute name: "foo", predicate: "hasFoo", clearer: "clearFoo"
  names = _.map attr4.methods(), (method) -> method.name()
  t.equivalent names.sort(),
    ["clearFoo", "foo", "hasFoo"],
    "methods includes reader, predicate, and clearer"

  attr5 = new Attribute name: "foo", access: "rw"
  t.equal attr5.accessor(), "foo", "rw attribute has an accessor method (not reader or writer)"
  t.ok ! attr5.hasReader(), "rw attribute does not have a reader"
  t.ok ! attr5.hasWriter(), "rw attribute does not have a writer"

  attr6 = new Attribute name: "foo", access: "ro", reader: "getFoo"
  t.equal attr6.reader(), "getFoo", "explicitly set reader name"
  t.ok ! attr6.hasAccessor(), "attr6 has no accessor"
  t.ok ! attr6.hasWriter(), "attr6 has no writer"

  t.end()

test "bad access", (t) ->
  try
    new Attribute name: "bad", access: "bad"
  catch e
    error = e

  t.equal error,
    'The access value for an attribute must be "bare, "ro" or "rw", not "bad"',
    "bad access throws an error"

  t.end()

test "bare attribute", (t) ->
  attr = new Attribute
    name: "bare"
    access: "bare"

  t.equal attr.access(), "bare", "access() returns bare"

  names = _.map attr.methods(), (method) -> method.name()
  t.equivalent names, [], "a bare attribute has no methods"

  t.end()

test "bad lazy", (t) ->
  try
    new Attribute name: "bad", lazy: true
  catch e
    error = e

  t.equal error,
    "You must provide a default or builder for a lazy attribute",
    "a lazy attribute must have a default"

  t.end()

test "method subclass", (t) ->
  class myMethod extends Method

  attr = new Attribute name: "foo", methodClass: myMethod

  method = attr.methods()[0]
  t.ok method, "attribute has at least one method"
  t.ok method instanceof myMethod, "attribute's method is a myMethod"

  t.end()
