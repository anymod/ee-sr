'use strict'

angular.module('store.sale').config ($stateProvider) ->

  $stateProvider

    .state 'doorbusters',
      url: '/doorbusters'
      views:
        top:
          controller: 'storeCtrl as storefront'
          templateUrl: 'store/doorbusters/doorbusters.header.html'
        middle:
          controller: 'homeCtrl as home'
          templateUrl: 'store/doorbusters/doorbusters.html'
        footer:
          controller: 'footerCtrl as storefront'
          templateUrl: 'ee-shared/storefront/storefront.footer.html'
