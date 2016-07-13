'use strict'

angular.module('eeStore').controller 'skuCtrl', ($rootScope, $stateParams, $location, eeDefiner, eeSku, eeProducts, eeCart) ->

  sku = this

  sku.id = parseInt($stateParams.id)
  sku.ee = eeDefiner.exports
  sku.data = sku.ee.Sku
  sku.currentUrl = $location.absUrl()

  searchLike = () ->
    return unless sku.data.sku?.title?
    eeProducts.fns.searchLike sku.data.sku.title, sku.data.sku.product.category_id

  if sku.ee.Sku?.sku?.id isnt sku.id
    eeSku.fns.defineSku sku.id
    .then () -> searchLike()
  else
    searchLike()

  return
