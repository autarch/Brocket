# Brocket - A self-hosting and self-extensible (meta)class system for Javascript

## Install

```bash
npm install Brocket
```

or for a global install

```bash
npm install -g Brocket
```

## What is it?

Brocket aims to make OO programming in JavaScript (or Coffeescript) easier and
more fun. It allows you to declare classes using a simple declarative DSL-ish
syntax.

Under the hood, Brocket is based on a powerful meta-model. Every aspect of
Brocket is itself a class, providing powerful introspectiona nd extension
features.

Brocket is a port of Perl's [Moose](http://moose.perl.org).

### Alpha Warning

This is an early version of Brocket. A lot of it isn't done. In particular, it
is not yet self-bootstrapping, so you cannot extend Brocket by using
Brocket-based classes (this will be coming in the future), and it does not
provide any code generation features to make things faster.

In other words, it's incomplete and slow.

## Synopsis

Creating a class with Brocket:

```javascript
Brocket = require("Brocket");
Person = Brocket.makeClass( "Person", function (B) {
    B.has( "firstName", { access: "ro" } );
    B.has( "lastName",  { access: "ro" } );
    B.has( "age",       { access: "ro", default: 0 } );

    B.method( "greet", function () {
        console.log "Hi, my name is " + this.firstName() + ".";
    } );
} );

User = Brocket.makeClass( "User", function (B) {
    B.extends(Person);
    B.has( "username",  { access: "rw" } );
    B.has( "password",  { access: "rw" } );
    B.has( "lastLogin", { access: "rw" } );

    B.method( "login", function (password) {
        if ( password != this.password() ) {
            return false;
        }

        this.lastLogin( new Date );

        return true;
    } );
} );

bob = new User ( {
    firstName: "Bob",
    lastName:  "Smith",
    username:  "bob.smith",
    password:  "password"
} );

bob.greet()

if ( bob.login(password) ) {
    ....
}
```

Here's a class example in CoffeeScript

```coffeescript
Brocket = require "Brocket"
Person = Brocket.makeClass "Person", (B) ->
    B.has "firstName", access: "ro"
    B.has "lastName",  access: "ro"
    B.has "age",       access: "ro", default: 0

    B.method "greet", ->
        console.log "Hi, my name is #{ @firstName() }."
```
