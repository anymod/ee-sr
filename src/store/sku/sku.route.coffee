'use strict'

angular.module('store.sku').config ($stateProvider) ->

  $stateProvider

    .state 'sku',
      url: '/s/:obfuscated_id/:title?'
      views:
        top:
          controller: 'skuCtrl as sku'
          templateUrl: 'store/sku/sku.header.html'
        middle:
          controller: 'skuCtrl as sku'
          templateUrl: 'store/sku/sku.html'
        footer:
          controller: 'storeCtrl as storefront'
          templateUrl: 'ee-shared/storefront/storefront.footer.html'
      params:
        title:
          value: null
          squash: true
