'use strict'

angular.module('store.home').controller 'favoriteCtrl', ($state, eeDefiner, eeFavorites) ->

  favorite = this

  favorite.ee = eeDefiner.exports
  favorite.fns = eeFavorites.fns

  eeFavorites.fns.setFavoritesCookieUnlessExists $state.params.obfuscated_id
  eeFavorites.fns.defineProducts $state.params.obfuscated_id

  # eeFavorites.fns.defineSkuIds()
  # eeFavorites.fns.defineProducts()

  return
