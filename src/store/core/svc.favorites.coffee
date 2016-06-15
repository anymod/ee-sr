'use strict'

angular.module('store.core').factory 'eeFavorites', ($rootScope, $state, $cookies, eeBootstrap, eeBack) ->

  ## SETUP
  #

  ## PRIVATE EXPORT DEFAULTS
  _data =
    reading:  false
    updating: false
    sku_ids: eeBootstrap?.favorites?.sku_ids || []

  ## PRIVATE FUNCTIONS
  _defineSkuIds = () ->
    return if !$cookies.get('favorites')
    _data.reading = true
    [ee, favorite_id, token] = $cookies.get('favorites')?.split('.')
    eeBack.fns.favoritesGET favorite_id
    .then (favorite) -> _data.sku_ids = favorite.sku_ids
    .finally () -> _data.reading = false

  _createOrUpdate = (email, sku_ids, on_mailing_list) ->
    # Update
    if $cookies.get('favorites')
      _data.updating = true
      [ee, favorite_id, token] = $cookies.get('favorites').split('.')
      eeBack.fns.favoritesPUT favorite_id, { sku_ids: sku_ids, token: token }
      .then (res) ->
        $cookies.put 'favorites', ['ee', res.id, res.uuid].join('.')
        $state.go 'favorites', null, reload: true
      .finally () -> _data.updating = false
    # Create
    else
      _data.updating = true
      eeBack.fns.favoritesPOST email, sku_ids, on_mailing_list
      .then (res) ->
        $cookies.put 'favorites', ['ee', res.id, res.uuid].join('.')
        $state.go 'favorites', null, reload: true
      .finally () -> _data.updating = false

  _addSku = (sku_id) -> return
  _removeSku = (sku_id) -> return

  ## MESSAGING
  #

  ## EXPORTS
  data: _data
  fns:
    addSku:         _addSku
    removeSku:      _removeSku
    defineSkuIds:   _defineSkuIds
    createOrUpdate: _createOrUpdate
