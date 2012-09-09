`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define (require) ->
  _       = require "underscore"
  Helpers = require "../../Helpers"
  util    = require "util"

  class Application
    apply: ->
      @_checkRequiredMethods()

      @_applyAttributes()
      @_applyMethods()

  #    @_applyOverrideMethodModifiers()
  #    @_applyBeforeMethodModifiers()
  #    @_applyAroundMethodModifiers()
  #    @_applyAfterMethodModifiers()

      return
