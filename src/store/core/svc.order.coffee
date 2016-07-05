'use strict'

angular.module('store.core').factory 'eeOrder', (eeBootstrap, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data =
    reading:  false
    order: {}

  ## PRIVATE FUNCTIONS
  _defineOrder = (uuid) ->
    _data.reading = true
    _data.order = {}
    eeBack.fns.orderGET uuid
    .then (ord) -> _data.order = ord
    .finally () -> _data.reading = false

  ## MESSAGING
  # none

  ## EXPORTS
  data: _data
  fns:
    defineOrder: _defineOrder
