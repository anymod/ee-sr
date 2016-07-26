'use strict'

angular.module('eeStore').controller 'modalCtrl', ($rootScope, $state, eeDefiner, eeProducts, eeModal, categories) ->

  modal = this

  modal.ee = eeDefiner.exports

  modal.search =
    minValue: 0
    maxValue: 300
    params:
      s: angular.copy eeProducts.data.params.s
      c: angular.copy eeProducts.data.params.c
    orderArray: eeProducts.data.orderArray
    categoryTitle: eeProducts.data.fromParams.categoryTitle
    categories: categories
    options:
      floor: 0
      ceil: 300
      step: 5
      hideLimitLabels: true
      translate: (value) -> if value < 300 then '$' + value else '>$' + value
      getSelectionBarColor: () -> '#F99'
      getPointerColor: () -> '#F99'
    update: () ->
      setSearchFromModal()
      $state.go 'search'
      eeModal.fns.close 'search'
      eeProducts.fns.runQuery()

  modal.setOrder = (order) ->
    console.log order, modal.search.params
    modal.search.params.s = if modal.search.params.s is order.order then null else order.order

  modal.setCategoryById = (categoryId) ->
    if categoryId is modal.search.params.c
      modal.search.params.c = null
      modal.search.categoryTitle = null
    for category in categories
      if category.id is parseInt(categoryId)
        modal.search.params.c = category.id
        modal.search.categoryTitle = category.title

  setModalFromSearch = () ->
    if eeProducts.data.params.r?
      [min, max] = eeProducts.data.params.r.split('-')
      modal.search.minValue = parseInt min
      modal.search.maxValue = parseInt max
    if modal.search.minValue < 0 then modal.search.minValue = 0
    if modal.search.maxValue > 300 then modal.search.maxValue = 300
    if eeProducts.data.params.s? then modal.search.orderTitle = eeProducts.data.fromParams.orderTitle
    if eeProducts.data.params.c? then modal.search.categoryTitle = eeProducts.data.fromParams.categoryTitle

  setSearchFromModal = () ->
    if modal.search.minValue? and modal.search.maxValue?
      min = if modal.search.minValue < 0 then 0 else modal.search.minValue
      max = if modal.search.maxValue >= 300 then 0 else modal.search.maxValue
      eeProducts.fns.setParam 'r', [min, max].join('-')
    if modal.search.params.s? then eeProducts.fns.setParam 's', modal.search.params.s
    if modal.search.params.c? then eeProducts.fns.setParam 'c', modal.search.params.c

  setModalFromSearch()

  $rootScope.$broadcast 'rzSliderForceRender'

  return
