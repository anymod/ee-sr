'use strict'

angular.module('store.signup').config ($stateProvider) ->

  $stateProvider

    .state 'signup',
      url: '/signup/:proposition'
      views:
        top:
          controller: 'storeCtrl as storefront'
          templateUrl: 'store/signup/signup.header.html'
        middle:
          controller: 'signupCtrl as signup'
          templateUrl: 'store/signup/signup.html'
        footer:
          controller: 'footerCtrl as storefront'
          templateUrl: 'ee-shared/storefront/storefront.footer.html'
      data:
        pageTitle:        'Signup'
        pageDescription:  'Join our list'
        padTop:           '51px'
