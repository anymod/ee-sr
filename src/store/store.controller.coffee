'use strict'

angular.module('eeStore').controller 'storeCtrl', ($state, $location, eeDefiner, eeUser, eeAnalytics, categories) ->

  storefront = this

  storefront.ee = eeDefiner.exports
  storefront.categories = categories
  storefront.state = $state.current.name

  if $state.current.name is 'storefront' and eeAnalytics.data.pageDepth > 1 then eeUser.fns.getUser()

  storefront.params = $location.search()
  if storefront.params
    storefront.query = storefront.params.q

  storefront.productsUpdate = () ->
    $state.go 'storefront', { p: storefront.ee.Products.storefront.page }

  return
