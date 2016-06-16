'use strict'

angular.module('store.sale').config ($stateProvider) ->

  $stateProvider

    .state 'sale',
      url: '/sale/:id/:title?q&p&s&r&coll'
      views:
        top:
          controller: 'storeCtrl as storefront'
          templateUrl: 'store/sale/sale.header.html'
        middle:
          controller: 'searchCtrl as search'
          templateUrl: 'store/sale/sale.html'
        footer:
          controller: 'storeCtrl as storefront'
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
