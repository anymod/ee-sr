'use strict'

angular.module('eeStore').controller 'productCtrl', ($stateParams, $location, eeDefiner, eeProduct, eeProducts) ->

  product = this

  product.ee = eeDefiner.exports
  product.data = product.ee.Product
  product.currentUrl = $location.absUrl()

  id          = parseInt($stateParams.id)
  title       = $stateParams.title?.replace(/-/g, ' ')
  category_id = $stateParams.c || null

  eeProduct.fns.defineProduct id
  eeProducts.fns.searchLike { id: id, title: title, category_id: category_id }

  return
