'use strict'

angular.module('store.checkout').config ($stateProvider) ->

  $stateProvider

    .state 'checkout-shipping',
      url: '/checkout/shipping'
      views:
        top:
          controller: 'checkoutCtrl as checkout'
          templateUrl: 'store/checkout/checkout.header.html'
        middle:
          controller:  'checkoutCtrl as checkout'
          templateUrl: 'store/checkout/checkout.shipping.html'
