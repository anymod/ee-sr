'use strict'

angular.module('eeStore').controller 'orderCtrl', (eeDefiner, eeOrder) ->

  order = this

  order.ee = eeDefiner.exports
  order.isNewOrder = false

  eeOrder.fns.executePaypalOrder()
  .then () ->
    order.isNewOrder = Math.abs(new Date() - new Date(eeOrder.data.order.created_at)) < 1800000 # 30 minutes

  return
