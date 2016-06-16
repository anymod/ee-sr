'use strict'

angular.module('store.core').factory 'eeFavorites', ($rootScope, $state, $cookies, eeBootstrap, eeBack) ->

  ## SETUP
  #

  ## PRIVATE EXPORT DEFAULTS
  _data =
    reading:  false
    updating: false
    logged_in: $cookies.get('favorites')?
    email_sent: false
    sku_ids: eeBootstrap?.favorites?.sku_ids || []

  ## PRIVATE FUNCTIONS
  _defineSkuIds = () ->
    return if !$cookies.get('favorites')?
    _data.reading = true
    [ee, favorite_id, token] = $cookies.get('favorites').split('.')
    eeBack.fns.favoritesGET favorite_id
    .then (favorite) ->
      _data.sku_ids = favorite.sku_ids
      $rootScope.$broadcast 'favorites:update'
    .finally () -> _data.reading = false

  _createOrUpdate = (email, sku_ids, on_mailing_list) ->
    # Update
    if $cookies.get('favorites')?
      _data.updating = true
      [ee, favorite_id, token] = $cookies.get('favorites').split('.')
      eeBack.fns.favoritesPUT favorite_id, { sku_ids: sku_ids, token: token }
      .then (res) -> _login res.id, res.uuid, res
      .finally () -> _data.updating = false
    # Create
    else
      _data.updating = true
      eeBack.fns.favoritesPOST email, sku_ids, on_mailing_list
      .then (res) -> _login res.id, res.uuid, res
      .finally () -> _data.updating = false

  _syncFavorites = () ->
    return if !$cookies.get('favorites')?
    _data.updating = true
    [ee, favorite_id, token] = $cookies.get('favorites').split('.')
    eeBack.fns.favoritesPUT favorite_id, { sku_ids: _data.sku_ids, token: token }
    .then (res) ->
      _data.sku_ids = res.sku_ids
      $rootScope.$broadcast 'favorites:update'
    .finally () -> _data.updating = false

  _addSku = (sku_id) ->
    if _data.sku_ids.indexOf(sku_id) < 0 then _data.sku_ids.push sku_id
    _syncFavorites()

  _removeSkus = (sku_ids) ->
    new_ids = []
    for sku_id in _data.sku_ids
      if sku_id? and sku_ids.indexOf(sku_id) < 0 and new_ids.indexOf(sku_id) < 0 then new_ids.push(sku_id)
    _data.sku_ids = new_ids
    _syncFavorites()

  _login = (id, uuid, res) ->
    if !id? or !uuid?
      if res?.message is 'success' then _data.email_sent = true
      return _logout()
    $cookies.put 'favorites', ['ee', id, uuid].join('.')
    _data.logged_in = true
    $state.go 'favorites', null, reload: true

  _logout = () ->
    $cookies.remove 'favorites'
    _data.sku_ids = []
    _data.logged_in = false
    # $state.go 'favorites', null, reload: true

  ## MESSAGING
  #

  ## AUTO RUN
  _defineSkuIds()

  ## EXPORTS
  data: _data
  fns:
    addSku:         _addSku
    removeSkus:     _removeSkus
    defineSkuIds:   _defineSkuIds
    createOrUpdate: _createOrUpdate
    logout:         _logout
