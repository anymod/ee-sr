'use strict'

angular.module('store.core').factory 'eeDefiner', ($rootScope, $filter, eeBootstrap, eeUser, eeProduct, eeProducts, eeCollection, eeCollections, eeCart, eeFavorites, eeOrder, eeCoupon) ->

  ## SETUP
  _exports =
    User:         eeUser.data
    Product:      eeProduct.data
    Products:     eeProducts.data
    Collection:   eeCollection.data
    Collections:  eeCollections.data
    Cart:         eeCart.data
    Favorites:    eeFavorites.data
    Order:        eeOrder.data
    Coupon:       eeCoupon.data

  _storeName = eeBootstrap.store_name

  ## PRIVATE FUNCTIONS
  _getPageTitle = (state, title) ->
    suffix = if _storeName then (' | ' + _storeName) else ''
    switch state
      when 'storefront', null then return 'Home' + suffix
      when 'product', 'category' then return $filter('humanize')(title) + suffix
      else return $filter('humanize')(state) + suffix

  ## MESSAGING ##
  $rootScope.$on '$stateChangeSuccess', (e, toState, toParams, fromState, fromParams) ->
    $rootScope.pageTitle = _getPageTitle toState.name, toParams.title

  ## EXPORTS
  exports: _exports
