'use strict'

angular.module('store.search').controller 'searchCtrl', ($location, $state, eeDefiner, eeProducts, eeCollection, eeAnalytics) ->

  search = this

  search.params = $location.search()
  search.ee = eeDefiner.exports

  search.update = () -> eeProducts.fns.runQuery()

  if eeAnalytics.data.pageDepth > 1
    switch $state.current.name
      when 'collection', 'sale' then eeCollection.fns.defineCollection $state.params.id, true

  return
