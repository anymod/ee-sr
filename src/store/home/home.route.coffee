'use strict'

angular.module('store.home').config ($stateProvider) ->

  $stateProvider

    .state 'storefront',
      url: '/'
      views:
        top:
          controller: 'storeCtrl as storefront'
          templateUrl: 'store/home/home.header.html'
        middle:
          controller: 'homeCtrl as home'
          templateUrl: 'store/home/home.html'
        # middle:
        #   controller: 'storeCtrl as storefront'
        #   templateUrl: 'ee-shared/storefront/storefront.carousel.html'
        footer:
          controller: 'footerCtrl as storefront'
          templateUrl: 'ee-shared/storefront/storefront.footer.html'
