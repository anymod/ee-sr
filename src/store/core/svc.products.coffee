'use strict'

angular.module('store.core').factory 'eeProducts', ($rootScope, $q, $state, $stateParams, $filter, eeBootstrap, eeBack, categories, stopWords) ->

  ## SETUP
  _params = $stateParams
  # Source of truth is query string params:
  # _params =
  #   q: query
  #   p: page
  #   sz: size
  #   s: sortStr e.g. "pa"
  #   r: rangeStr e.g. "0-45"
  #   c: category_id
  #   coll: collection_id

  _fromParams =
    perPage:        eeBootstrap?.perPage
    categoryTitle:  null
    orderTitle:     null
    queryTokens:    []

  _orderArray = [
    { order: null,  title: 'Most relevant' }
    { order: 'pa',  title: '$ - $$$', use: true } # price ASC (pa)
    { order: 'pd',  title: '$$$ - $', use: true } # price DESC (pd)
    { order: 'ta',  title: 'A to Z',  use: true } # title ASC (ta)
    { order: 'td',  title: 'Z to A',  use: true } # title DESC (td)
  ]

  ## PRIVATE EXPORT DEFAULTS
  _data =
    reading:      false
    params:       _params
    fromParams:   angular.copy _fromParams
    products:     eeBootstrap?.products
    count:        eeBootstrap?.count
    categories:   categories
    orderArray:   _orderArray
    defaultSize:  eeBootstrap?.perPage || 48
    similarSize:  48

  ## PRIVATE FUNCTIONS
  _setParam = (key, value, opts) ->
    opts ||= {}
    if opts.resetParams? then $stateParams = {}
    $stateParams[key] = value
    if opts.goTo? then return $state.go opts.goTo, $stateParams
    return

  _setParams = (obj, opts) ->
    obj ||= {}
    opts ||= {}
    _setParam key, obj[key] for key in Object.keys(obj)
    if opts.goTo? then return $state.go opts.goTo, $stateParams
    return

  _clearParams = () -> _setParam(key, null) for key in Object.keys($stateParams)

  _formQuery = () ->
    query = {}
    if $stateParams.q?
      _tokenizeQuery $stateParams.q
      query.search = $stateParams.q
    if $stateParams.r is '0-0' then _setParam 'r', null
    if $stateParams.r?
      query.min_price = parseInt($stateParams.r.split('-')[0]) * 100
      query.max_price = parseInt($stateParams.r.split('-')[1]) * 100
    if $stateParams.p?    then query.page           = parseInt $stateParams.p
    if $stateParams.sz?   then query.size           = parseInt $stateParams.sz
    if $stateParams.s?    then query.order          = $stateParams.s
    if $stateParams.c?    then query.category_ids   = [$stateParams.c]
    if $stateParams.coll? then query.collection_id  = parseInt $stateParams.coll
    _data.params = $stateParams
    _setFromParams()
    query

  _setFromParams = () ->
    _data.fromParams = angular.copy _fromParams
    if $stateParams.q? then _data.fromParams.queryTokens = _tokenizeQuery $stateParams.q
    if $stateParams.sz? then _data.fromParams.perPage = parseInt $stateParams.sz
    if $stateParams.s?
      for order in _data.orderArray
        if order.order is $stateParams.s then _data.fromParams.orderTitle = order.title
    if $stateParams.c?
      for category in categories
        if category.id is parseInt($stateParams.c) then _data.fromParams.categoryTitle = category.title

  _tokenizeQuery = (query) ->
    query ||= ''
    query = query.replace(/[^a-zA-Z0-9]|^ /gi, ' ').replace(/ +/g,' ').toLowerCase()
    words = query.split(/[ ,]/g)
    tokenArray = []
    _addTokenToArray word, tokenArray for word in words
    _setParam 'q', tokenArray.join(' ')
    tokenArray

  _addTokenToArray = (word, arr) ->
    return if !word? or word.length < 1 or word is 'null'
    capitalized = word.charAt(0).toUpperCase() + word.toLowerCase().slice(1)
    return if arr.indexOf(capitalized) > -1 or (word.length is 1 and isNaN(word))
    return if stopWords.indexOf(word.toLowerCase()) > -1
    arr.push capitalized

  _clearProducts = () ->
    _setParam 'sz', null
    _data.products = []
    _data.count    = 0

  _runQuery = () ->
    if _data.reading then return $q.when()
    _data.reading = true
    eeBack.fns.productsGET _formQuery()
    .then (res) ->
      { rows, count, took } = res
      _data.products  = rows
      _data.count     = count
      _data.took      = took
    .catch (err) -> _data.count = null
    .finally () -> _data.reading = false

  _searchLike = (product, opts) ->
    opts ||= {}
    _clearProducts()
    _clearParams() unless opts.silent?
    _setParam 'c', product.category_id
    _setParam 'q', product.title
    _setParam 'sz', _data.similarSize + 1
    _runQuery()
    .then () ->
      products = []
      for prod, i in _data.products
        if products.length < _data.similarSize and prod.id isnt product.id then products.push prod
      _data.products = products
      _setParam 'sz', null
      return

  _addToQuery = (term, opts) ->
    term ||= ''
    opts ||= {}
    prefix = if opts.overwrite then '' else (_data.params.q || '') + ' '
    _tokenizeQuery prefix + term

  ## Set initial values from URL
  _formQuery()

  ## MESSAGING
  $rootScope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
    switch toState.name
      when 'category' then toParams.c = toParams.id
      when 'collection', 'sale' then toParams.coll = toParams.id
    _setParams toParams
    _runQuery()
    return

  $rootScope.$on 'product:navigate', (e, prod) -> _searchLike prod, { silent: true }

  ## EXPORTS
  data: _data
  fns:
    runQuery: _runQuery
    setParam: _setParam
    setParams: _setParams
    clearParams: _clearParams
    addToQuery: _addToQuery
    searchLike: _searchLike
