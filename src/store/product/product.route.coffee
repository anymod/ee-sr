'use strict'

angular.module('store.product').config ($stateProvider) ->

  $stateProvider

    .state 'product',
      url: '/products/:id/:title?p&s&r&c&sz'
      views:
        top:
          controller: 'storeCtrl as store'
          templateUrl: 'store/product/product.header.html'
        middle:
          controller: 'productCtrl as product'
          templateUrl: 'store/product/product.html'
        footer:
          controller: 'footerCtrl as storefront'
          templateUrl: 'ee-shared/storefront/storefront.footer.html'
      params:
        title:
          value: null
          squash: true
        p: null # page
        s: null # sort
        r: null # range
        c: null # category
        sz: null # size
