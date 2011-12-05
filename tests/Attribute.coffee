test = (require "tap").test
_    = require "underscore"
util = require "util"

Attribute = require "../lib/Brocket/Meta/Attribute";
Base      = (require "../lib/Brocket/Base")
Class     = (require "../lib/Brocket/Meta/Class")

test "attribute basics", (t) ->
  attr = new Attribute name: "foo"
  t.equal attr.name(), "foo", "name() returns expected value"
  t.equal attr.access(), "ro", "access() defaults to ro"
  t.equal attr.required(), false, "required() defaults to false"
  t.equal attr.isLazy(), false, "isLazy() defaults to false"
  t.equal attr.reader(), "foo", "reader() defaults to attr name"
  t.ok ( ! attr.hasWriter() ), "attr has no writer"
  t.ok ( ! attr.hasPredicate() ), "attr has no predicate"
  t.ok ( ! attr.hasClearer() ), "attr has no clearer"

  names = _.map attr.methods(), (attr) -> attr.name()
  t.equivalent names, ["foo"], "methods returns a single method named foo"

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

  names = _.map attr.methods(), (attr) -> attr.name()
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