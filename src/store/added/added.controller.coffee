'use strict'

angular.module('eeStore').controller 'addedCtrl', ($state, eeDefiner, eeCart, eeProducts) ->

  added = this

  added.ee = eeDefiner.exports
  added.$state = $state

  eeCart.fns.defineCart()
  eeProducts.fns.searchLike { q: $state.toParams?.q }

  return
