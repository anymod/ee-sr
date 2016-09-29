'use strict'

angular.module('store.collections').config ($stateProvider) ->

  $stateProvider

    .state 'collection',
      url: '/collections/:id/:title?q&p&s&r&coll'
      views:
        top:
          controller: 'storeCtrl as storefront'
          templateUrl: 'store/search/search.header.html'
        middle:
          controller: 'searchCtrl as search'
          templateUrl: 'store/search/search.html'
        footer:
          controller: 'footerCtrl as storefront'
          templateUrl: 'ee-shared/storefront/storefront.footer.html'
      params:
        q: null # query
        p: null # page
        s: null # sort
        r: null # range
        coll: null # collection
        title:
          value: null
          squash: true
