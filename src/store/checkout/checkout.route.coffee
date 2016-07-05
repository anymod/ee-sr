'use strict'

angular.module('store.checkout').config ($stateProvider) ->

  $stateProvider

    .state 'checkout',
      url: '/checkout/:cart_uuid'
      views:
        top:
          controller: 'checkoutCtrl as checkout'
          templateUrl: 'store/checkout/checkout.header.html'
        middle:
          controller:  'checkoutCtrl as checkout'
          templateUrl: 'store/checkout/checkout.html'
