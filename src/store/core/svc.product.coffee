'use strict'

angular.module('store.core').factory 'eeProduct', ($rootScope, $state, $filter, eeBootstrap, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data =
    reading:  false
    product:  eeBootstrap?.product

  ## PRIVATE FUNCTIONS
  _defineProduct = (id, opts) ->
    opts ||= {}
    _data.reading = true unless opts.silent
    _data.product = {} unless opts.silent
    eeBack.fns.productGET id
    .then (prod) ->
      _data.product = prod
      $rootScope.$broadcast 'product:loaded', prod
    .finally () -> _data.reading = false

  ## MESSAGING
  $rootScope.$on 'product:navigate', (e, prod) ->
    return unless prod?.id? and prod.skus?.length > 0
    if !prod.skus[0].selection_text? then _defineProduct prod.id, { silent: true }
    _data.product = prod
    return

  ## EXPORTS
  data: _data
  fns:
    defineProduct: _defineProduct
