'use strict'

angular.module('eeStore').controller 'storeCtrl', ($state, $stateParams, eeDefiner, eeUser, eeCoupon, eeAnalytics, categories) ->

  storefront = this

  storefront.ee = eeDefiner.exports
  storefront.categories = categories
  storefront.state = $state.current.name
  storefront.params = $stateParams
  if storefront.params then storefront.query = storefront.params.q

  storefront.productsUpdate = () ->
    $state.go 'storefront', { p: storefront.ee.Products.storefront.page }

  switch $state.current.name
    when 'storefront'
      if eeAnalytics.data.pageDepth > 1 then eeUser.fns.getUser()
    when 'coupon'
      if !$state.params.uuid? or $state.params.uuid is '' then return $state.go 'storefront'
      if !eeCoupon.data.coupon?.id then eeCoupon.fns.defineCoupon $state.params.uuid

  return
