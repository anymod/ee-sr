'use strict'

angular.module('store.favorites').config ($stateProvider) ->

  $stateProvider

    .state 'favorites',
      url: '/favorites'
      views:
        top:
          controller: 'storeCtrl as storefront'
          templateUrl: 'store/favorites/favorites.header.html'
        middle:
          controller: 'favoritesCtrl as favorites'
          templateUrl: 'store/favorites/favorites.html'
        footer:
          controller: 'storeCtrl as storefront'
          templateUrl: 'ee-shared/storefront/storefront.footer.html'
