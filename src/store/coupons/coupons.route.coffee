'use strict'

angular.module('store.coupons').config ($stateProvider) ->

  $stateProvider

    .state 'coupon',
      url: '/discounts/{uuid}'
      views:
        top:
          controller: 'storeCtrl as storefront'
          templateUrl: 'store/home/home.header.html'
        middle:
          controller: 'homeCtrl as home'
          templateUrl: 'store/home/home.html'
        footer:
          controller: 'footerCtrl as storefront'
          templateUrl: 'ee-shared/storefront/storefront.footer.html'
