'use strict'

angular.module('eeStore').controller 'modalCtrl', (eeBack, eeDefiner, eeModal) ->

  modal = this

  modal.ee = eeDefiner.exports

  return
