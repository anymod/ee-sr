'use strict'

angular.module('eeStore').controller 'cartCtrl', ($window, $cookies, eeDefiner, eeSecureUrl, eeCart, eeProducts) ->

  cart = this

  cart.ee = eeDefiner.exports
  cart.showPaypalButton = false

  ###### OLD

  eeCart.fns.defineCart()
  .then () ->
    if eeCart.data.skus?.length < 1 then eeProducts.fns.clearParams()


  cart.removeSku = (sku_id) -> eeCart.fns.removeSku sku_id

  cart.buy = () ->
    if cart.ee.Cart?.skus?.length > 0
      cart.processing = true
      $window.location.assign(eeSecureUrl + 'checkout/' + $cookies.get('cart')?.split('.')[2])

  cart.update = () -> eeCart.fns.createOrUpdate()

  return
