'use strict'

angular.module('store.core').factory 'eeCoupon', ($q, $cookies, eeBack) ->

  ## SETUP
  _uuid = () -> $cookies.get 'coupon'

  ## PRIVATE EXPORT DEFAULTS
  _data =
    reading:  false
    coupon: {}

  ## PRIVATE FUNCTIONS
  _defineCoupon = (uuid) ->
    uuid ||= _uuid()
    return $q.resolve() if !uuid?
    _data.reading = true
    eeBack.fns.couponGET uuid
    .then (coupon) ->
      if coupon?.uuid? then $cookies.put 'coupon', coupon.uuid
      _data.coupon = coupon
    .finally () -> _data.reading = false

  ## MESSAGING
  # None

  ## EXPORTS
  data: _data
  fns:
    defineCoupon: _defineCoupon
