'use strict'

angular.module('store.search').controller 'searchCtrl', ($state, $stateParams, eeDefiner, eeProducts, eeCollection, eeAnalytics) ->

  search = this

  search.params = $stateParams
  search.ee = eeDefiner.exports

  search.update = () ->
    eeProducts.fns.setParam 'p', search.ee.Products.params.p, { goTo: $state.current.name }

  if eeAnalytics.data.pageDepth > 1
    switch $state.current.name
      when 'collection', 'sale' then eeCollection.fns.defineCollection $state.params.id, true

  return
