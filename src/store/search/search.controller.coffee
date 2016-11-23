'use strict'

angular.module('store.search').controller 'searchCtrl', ($state, $stateParams, eeDefiner, eeProducts, eeCollection, eeAnalytics) ->

  search = this

  search.params = $stateParams
  search.ee = eeDefiner.exports

  search.update = () ->
    eeProducts.fns.setParam 'p', search.ee.Products.params.p, { goTo: $state.current.name }

  if eeAnalytics.data.pageDepth > 1
    if search.ee.Products.params?.coll > 0 then eeCollection.fns.defineCollection search.ee.Products.params.coll, true

  if $state.current.name is 'doorbuster' and $stateParams.handle?
    params =
      t1: 'doorbusters'
      t2: 'doorbusters-fall-2016'
      t3: '' + $stateParams.handle
    eeProducts.fns.setParams params, { goTo: $state.current?.name }

  search.doorbusters =
    'statement-furniture-pieces':
      title: 'Signature Furniture Pieces'
      image: 'https://res.cloudinary.com/eeosk/image/upload/v1479920067/doorbusters-1-crop_u98ezo.png'
    'signature-lighting':
      title: 'Statement Lighting'
      image: 'https://res.cloudinary.com/eeosk/image/upload/v1479920066/doorbusters-2-crop_lbno6u.png'
    'steals-under-100':
      title: 'Steals under $100'
      image: 'https://res.cloudinary.com/eeosk/image/upload/v1479920066/doorbusters-3-crop_wdzueg.png'


  return
