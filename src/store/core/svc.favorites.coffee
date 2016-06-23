'use strict'

angular.module('store.core').factory 'eeFavorites', ($rootScope, $q, $state, $cookies, eeBootstrap, eeBack) ->

  ## SETUP
  _cookieParts = () ->
    cookie = $cookies.get 'favorites'
    return {} if !cookie?
    [ee, obfuscated_id, uuid] = cookie.split('.')
    if obfuscated_id is "" then obfuscated_id = null
    if uuid is "" then uuid = null
    {
      obfuscated_id: obfuscated_id
      uuid: uuid
    }

  _obfuscatedId = () -> _cookieParts().obfuscated_id
  _uuid = () -> _cookieParts().uuid

  ## PRIVATE EXPORT DEFAULTS
  _data =
    reading:  false
    updating: false
    uuid: _uuid()
    obfuscated_id: _obfuscatedId()
    email_sent: false
    sku_ids: []
    products: []

  ## PRIVATE FUNCTIONS
  _skuIdsPromise = () ->
    eeBack.fns.favoritesGET _obfuscatedId()
    .then (favorite) -> _data.sku_ids = favorite.sku_ids

  _productsPromise = (obfuscated_id) ->
    return if !obfuscated_id?
    eeBack.fns.favoriteProductsGET obfuscated_id
    .then (res) -> _data.products = res.rows

  _defineSkuIdsAndProducts = (obfuscated_id) ->
    obfuscated_id ||= _obfuscatedId()
    return if !obfuscated_id?
    _data.reading = true
    $q.all([_skuIdsPromise(), _productsPromise(obfuscated_id)])
    .then () -> $rootScope.$broadcast 'favorites:update'
    .finally () -> _data.reading = false

  _createOrUpdate = (email, on_mailing_list) ->
    # Update
    if _uuid()? and _obfuscatedId()?
      _data.updating = true
      eeBack.fns.favoritesPUT _obfuscatedId(), { sku_ids: _data.sku_ids, token: _uuid() }
      .then (res) -> _login res.obfuscated_id, res.uuid, res
      .finally () -> _data.updating = false
    # Create
    else
      _data.updating = true
      eeBack.fns.favoritesPOST email, _data.sku_ids, on_mailing_list
      .then (res) ->
        if res?.obfuscated_id and res?.uuid then _login(res.obfuscated_id, res.uuid, res)
        _data.email_sent = true
      .finally () -> _data.updating = false

  _syncFavorites = () ->
    return if !$cookies.get('favorites')?
    _data.updating = true
    eeBack.fns.favoritesPUT _obfuscatedId(), { sku_ids: _data.sku_ids, token: _uuid() }
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

  _login = (obfuscated_id, uuid, res) ->
    if !obfuscated_id? and res?.message is 'success' then _data.email_sent = true
    $cookies.put 'favorites', ['ee', obfuscated_id, uuid].join('.')
    _data.uuid = uuid
    _data.obfuscated_id = obfuscated_id
    $state.go 'favorite', { obfuscated_id: obfuscated_id }, reload: true

  _logout = (stop_redirect) ->
    _data.sku_ids = []
    _data.uuid = null
    _data.obfuscated_id = null
    $cookies.remove 'favorites'
    $state.go 'favorites', null, reload: true unless stop_redirect

  _redirectIfLoggedIn = () ->
    if _uuid()? or _obfuscatedId()? then $state.go('favorite', { obfuscated_id: _obfuscatedId() })
    if !_uuid()? and !_obfuscatedId() then _logout(true)

  _setFavoritesCookieUnlessExists = (obfuscated_id, uuid) ->
    return if _uuid()? and !uuid?
    _login obfuscated_id, uuid

  ## MESSAGING
  #

  ## AUTO RUN
  # _defineSkuIds()

  ## EXPORTS
  data: _data
  fns:
    addSku:         _addSku
    removeSkus:     _removeSkus
    createOrUpdate: _createOrUpdate
    logout:         _logout
    redirectIfLoggedIn: _redirectIfLoggedIn
    setFavoritesCookieUnlessExists: _setFavoritesCookieUnlessExists
    defineSkuIdsAndProducts: _defineSkuIdsAndProducts
