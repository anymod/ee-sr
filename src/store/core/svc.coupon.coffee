'use strict'

angular.module('store.core').factory 'eeCoupon', ($rootScope, $q, $cookies, eeBack) ->

  ## SETUP
  _uuid = () -> $cookies.get 'coupon'

  ## PRIVATE EXPORT DEFAULTS
  _data =
    reading:  false
    coupon:   {}
    alert:    ''

  ## PRIVATE FUNCTIONS
  _defineCoupon = (code_or_uuid) ->
    code_or_uuid ||= _uuid()
    return $q.resolve() if !code_or_uuid?
    _data.reading = true
    _data.alert = ''
    eeBack.fns.couponGET code_or_uuid
    .then (coupon) ->
      if coupon?.uuid? then $cookies.put 'coupon', coupon.uuid
      _data.coupon = coupon
      $rootScope.$broadcast 'coupon:added', coupon
    .catch (err) -> _data.alert = err.message
    .finally () -> _data.reading = false

  _removeCoupon = () ->
    $cookies.remove 'coupon'
    _data.coupon = {}
    $rootScope.$broadcast 'coupon:removed'

  ## MESSAGING
  # None

  ## EXPORTS
  data: _data
  fns:
    defineCoupon: _defineCoupon
    removeCoupon: _removeCoupon
