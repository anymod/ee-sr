'use strict'

angular.module('eeStore').controller 'footerCtrl', (eeDefiner, categories) ->

  storefront = this

  storefront.ee = eeDefiner.exports
  storefront.categories = categories

  return
