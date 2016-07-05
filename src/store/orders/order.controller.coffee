'use strict'

angular.module('eeStore').controller 'orderCtrl', ($state, eeDefiner, eeOrder, eeCart) ->

  order = this

  order.ee = eeDefiner.exports
  order.isNewOrder = false

  eeOrder.fns.defineOrder $state.params.uuid
  .then () ->
    order.isNewOrder = Math.abs(new Date() - new Date(eeOrder.data.order.created_at)) < 1800000 # 30 minutes
    eeCart.fns.logoutIfUUID eeOrder.data.order.cart_uuid

  return
