'use strict'

angular.module('eeStore').controller 'modalCtrl', ($rootScope, $state, eeDefiner, eeProducts, eeModal, categories) ->

  modal = this

  modal.ee = eeDefiner.exports

  modal.search =
    minValue: 0
    maxValue: 300
    order: {}
    orderArray: eeProducts.data.inputs.orderArray
    category: null
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

  modal.setOrder = (order) -> modal.search.order = if modal.search.order?.title is order.title then {} else order
  modal.setCategory = (category) -> modal.search.category = if modal.search.category?.title is category.title then {} else category

  setModalFromSearch = () ->
    if eeProducts.data.inputs.range.min then modal.search.minValue = parseInt(eeProducts.data.inputs.range.min / 100)
    if eeProducts.data.inputs.range.max then modal.search.maxValue = parseInt(eeProducts.data.inputs.range.max / 100)
    if modal.search.minValue < 0 then modal.search.minValue = 0
    if modal.search.maxValue > 300 then modal.search.maxValue = 300
    if eeProducts.data.inputs.order then modal.search.order = eeProducts.data.inputs.order
    if eeProducts.data.inputs.category then modal.search.category = eeProducts.data.inputs.category

  setSearchFromModal = () ->
    eeProducts.data.inputs.range.min = if modal.search.minValue <= 0 then 0 else modal.search.minValue * 100
    eeProducts.data.inputs.range.max = if modal.search.maxValue >= 300 then null else modal.search.maxValue * 100
    eeProducts.data.inputs.order = modal.search.order
    eeProducts.data.inputs.category = modal.search.category

  setModalFromSearch()

  $rootScope.$broadcast 'rzSliderForceRender'

  return
