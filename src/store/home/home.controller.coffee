'use strict'

angular.module('store.home').controller 'homeCtrl', (eeDefiner, eeUser, eeAnalytics) ->

  home = this

  home.ee = eeDefiner.exports

  if eeAnalytics.data.pageDepth > 1 then eeUser.fns.getUser()

  return
