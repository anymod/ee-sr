'use strict'

angular.module('eeStore').controller 'modalCtrl', ($rootScope, eeDefiner, categories) ->

  modal = this

  modal.ee = eeDefiner.exports
  modal.categories = categories

  modal.search =
    minValue: 0
    maxValue: 300
    options:
      floor: 0
      ceil: 300
      step: 5
      hideLimitLabels: true
      translate: (value) -> if value < 300 then '$' + value else '>$' + value
      getSelectionBarColor: () -> '#F99'
      getPointerColor: () -> '#F99'
    update: () ->
      console.log 'foo'

  $rootScope.$broadcast 'rzSliderForceRender'

  return
