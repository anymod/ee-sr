'use strict'

angular.module('eeStore').controller 'orderCtrl', ($state, eeDefiner, eeOrder) ->

  order = this

  order.ee = eeDefiner.exports

  eeOrder.fns.defineOrder $state.params.uuid

  return
