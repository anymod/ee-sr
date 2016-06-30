'use strict'

angular.module('store.order').config ($stateProvider) ->

  $stateProvider

    .state 'order',
      url: '/orders/:uuid'
      views:
        top:
          controller: 'storeCtrl as storefront'
          templateUrl: 'store/orders/order.header.html'
        middle:
          controller:  'orderCtrl as order'
          templateUrl: 'store/orders/order.html'
