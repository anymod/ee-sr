'use strict'

angular.module('store.core').factory 'eeCart', ($q, $rootScope, $state, $cookies, eeBootstrap, eeBack) ->

  ## SETUP
  _cookieParts = () ->
    cookie = $cookies.get 'cart'
    return {} if !cookie?
    [ee, id, uuid] = cookie.split('.')
    if id is "" then id = null
    if uuid is "" then uuid = null
    {
      id: id
      uuid: uuid
    }

  _id = () -> _cookieParts().id
  _uuid = () -> _cookieParts().uuid

  ## PRIVATE EXPORT DEFAULTS
  _data =
    reading:  false
    updating: false
    quantity_array: eeBootstrap?.cart?.quantity_array || []
    skus: eeBootstrap?.cart?.skus || []
    cart: eeBootstrap?.cart
    id: _id()
    uuid: _uuid()

  ## PRIVATE FUNCTIONS
  _login = (id, uuid) ->
    if !id? or !uuid? then return
    $cookies.put 'cart', ['ee', id, uuid].join('.')
    _data.id = id
    _data.uuid = uuid

  _logout = () ->
    _data.id = null
    _data.uuid = null
    $cookies.remove 'cart'

  _logoutIfUUID = (uuid) ->
    if uuid is _uuid() then _logout()

  _defineCart = () ->
    return $q.resolve() if !_id()? or !_uuid()?
    _data.reading = true
    eeBack.fns.cartGET _id()
    .then (cart) ->
      _data.cart = cart
      _data.quantity_array = cart.quantity_array
      _syncSkus()
    .finally () -> _data.reading = false

  _getSku = (pair) ->
    _data.updating = true
    eeBack.fns.skuGET pair.product_id, pair.sku_id
    .then (fullSku) ->
      delete fullSku[attr] for attr in ['baseline_price']
      fullSku
    .finally () ->
      _data.updating = false

  _addDataSku = (pair) ->
    _getSku pair
    .then (fullSku) ->
      _data.skus.push fullSku

  _syncSku = (pair, sku) ->
    _getSku pair
    .then (fullSku) ->
      sku[attr] = fullSku[attr] for attr in Object.keys(fullSku)

  _syncSkus = () ->
    for pair in _data.quantity_array
      matchSku = undefined
      for sku in _data.skus
        if sku.id is pair.sku_id then matchSku = sku
      if !matchSku
        _addDataSku pair
      else if !matchSku.price?
        _syncSku pair, matchSku

  _addOrIncrement = (sku) ->
    inArray = false
    for pair, i in _data.quantity_array
      if parseInt(sku.id) is parseInt(pair.sku_id)
        pair.quantity += 1
        inArray = true
        break
    _data.quantity_array.push { sku_id: sku.id, product_id: sku.product_id, quantity: 1 } unless inArray

  _createOrUpdate = (added_id, searchLike) ->
    # Update
    if _id()? and _uuid()
      _data.updating = true
      eeBack.fns.cartPUT _id(), { quantity_array: _data.quantity_array, token: _uuid() }
      .then (res) ->
        _login res.id, res.uuid
        if added_id then $state.go 'added', { id: added_id, q: searchLike } else $state.go 'cart', null, reload: true
      .catch (err) -> console.error err
      .finally () -> _data.updating = false
    # Create
    else
      _logout()
      _data.updating = true
      eeBack.fns.cartPOST _data.quantity_array
      .then (res) ->
        _login res.id, res.uuid
        if added_id then $state.go 'added', { id: added_id, q: searchLike } else $state.go 'cart', null, reload: true
      .catch (err) -> console.error err
      .finally () -> _data.updating = false

  _addSku = (sku, searchLike) ->
    _addOrIncrement sku
    _createOrUpdate sku.product_id, searchLike

  _removeSku = (sku_id) ->
    tempQA = []
    for pair in _data.quantity_array
      if parseInt(sku_id) isnt parseInt(pair.sku_id) then tempQA.push pair
    _data.quantity_array = tempQA
    tempSkus = []
    for sku in _data.skus
      if parseInt(sku_id) isnt parseInt(sku.id) then tempSkus.push sku
    _data.skus = tempSkus
    _createOrUpdate()

  ## MESSAGING
  $rootScope.$on 'cart:add:sku', (e, data) -> _addSku data.sku, data.searchLike
  $rootScope.$on 'cart:logout', (e, uuid) -> _logoutIfUUID uuid
  $rootScope.$on 'coupon:added', (e, coupon) ->
    if _data.cart?.uuid? and coupon?.uuid?
      _data.cart.coupon_uuid = coupon.uuid
      _createOrUpdate()
  $rootScope.$on 'coupon:removed', (e) ->
    if _data.cart?.uuid?
      _data.cart.coupon_uuid = null
      _createOrUpdate()

  ## EXPORTS
  data: _data
  fns:
    removeSku:    _removeSku
    defineCart:   _defineCart
    createOrUpdate: _createOrUpdate
