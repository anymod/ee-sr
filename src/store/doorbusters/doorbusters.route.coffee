'use strict'

angular.module('store.sale').config ($stateProvider) ->

  $stateProvider

    .state 'doorbusters',
      url: '/'
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

    .state 'doorbuster',
      url: '/doorbusters/:handle?q&p&s&r&c&t1&t2&t3'
      views:
        top:
          controller: 'storeCtrl as storefront'
          templateUrl: 'store/home/home.header.html'
        middle:
          controller: 'searchCtrl as search'
          templateUrl: 'store/doorbusters/doorbuster.html'
        footer:
          controller: 'footerCtrl as storefront'
          templateUrl: 'ee-shared/storefront/storefront.footer.html'
      params:
        q: null # query
        p: null # page
        s: null # sort
        r: null # range
        c: null # category
        t1: null # tags1
        t2: null # tags2
        t3: null # tags3
