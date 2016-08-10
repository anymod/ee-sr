'use strict'

angular.module('eeStore').controller 'modalCtrl', ($rootScope, $state, $stateParams, eeDefiner, eeProducts, eeModal, categories) ->

  modal = this

  modal.ee = eeDefiner.exports

  modal.search =
    minValue: 0
    maxValue: 300
    data: eeProducts.data
    categories: categories
    options:
      floor: 0
      ceil: 300
      step: 5
      hideLimitLabels: true
      translate: (value) -> if value < 300 then '$' + value else '>$' + value
    update: () ->
      setSearchFromModal()
      $state.go 'search', $stateParams # , { notify: $state.current.name isnt 'search' }
      eeModal.fns.close 'search'

  modal.setOrder = (order) ->
    modal.search.data.params.s = if modal.search.data.params.s is order.order then null else order.order

  modal.setCategoryById = (categoryId) ->
    if categoryId is parseInt(modal.search.data.params.c)
      modal.search.data.params.c = null
      modal.search.data.categoryTitle = null
    else
      for category in categories
        if category.id is parseInt(categoryId)
          modal.search.data.params.c = category.id
          modal.search.data.categoryTitle = category.title

  setModalFromSearch = () ->
    if eeProducts.data.params.r?
      [min, max] = eeProducts.data.params.r.split('-')
      modal.search.minValue = parseInt min
      modal.search.maxValue = parseInt max
    if modal.search.minValue < 0 then modal.search.minValue = 0
    if modal.search.maxValue > 300 or modal.search.maxValue <= modal.search.minValue then modal.search.maxValue = 300
    if eeProducts.data.params.s? then modal.search.orderTitle = eeProducts.data.fromParams.orderTitle
    if eeProducts.data.params.c? then modal.search.data.categoryTitle = eeProducts.data.fromParams.categoryTitle

  setSearchFromModal = () ->
    $rootScope.$broadcast 'search:submit'
    eeProducts.fns.setParam 'p', 1
    if modal.search.minValue? and modal.search.maxValue?
      min = if modal.search.minValue < 0 then 0 else modal.search.minValue
      max = if modal.search.maxValue >= 300 then 0 else modal.search.maxValue
      eeProducts.fns.setParam 'r', [min, max].join('-')
    eeProducts.fns.setParam 's', modal.search.data.params.s
    eeProducts.fns.setParam 'c', modal.search.data.params.c, { goTo: 'search' }

  setModalFromSearch()

  $rootScope.$broadcast 'rzSliderForceRender'

  return
