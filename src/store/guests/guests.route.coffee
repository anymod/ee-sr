'use strict'

angular.module('store.guests').config ($stateProvider) ->

  $stateProvider

    .state 'guests_simple_stylings',
      url: '/guests/simple-stylings'
      views:
        top:
          controller: 'storeCtrl as storefront'
          templateUrl: 'store/home/home.header.html'
        middle:
          controller: 'guestsCtrl as guests'
          templateUrl: 'store/guests/simplestylings.html'
        footer:
          controller: 'footerCtrl as storefront'
          templateUrl: 'ee-shared/storefront/storefront.footer.html'
