'use strict'

angular.module('store.core').factory 'eeOrder', ($rootScope, $state, $location, eeBootstrap, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data =
    reading: false
    order: {}

  ## PRIVATE FUNCTIONS
  _defineOrder = (uuid) ->
    _data.reading = true
    _data.order = {}
    eeBack.fns.orderGET uuid
    .then (ord) -> _data.order = ord
    .finally () -> _data.reading = false

  _executePaypalOrder = () ->
    _data.reading = true
    eeBack.fns.paymentPUT $state.params.uuid, $location.search().paymentId, $location.search().PayerID
    .then (ord) ->
      console.log 'ord', ord
      _data.order = ord
      $rootScope.$broadcast 'cart:logout', ord.cart_uuid
    .finally () -> _data.reading = false

  ## MESSAGING
  # none

  ## EXPORTS
  data: _data
  fns:
    executePaypalOrder: _executePaypalOrder
