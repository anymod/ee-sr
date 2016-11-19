'use strict'

angular.module('store.core').factory 'eeProducts', ($rootScope, $q, $state, $stateParams, eeBootstrap, eeBack, tagTree, sortOrders, stopWords) ->

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
  #   t: tag
  #   t1: tags1
  #   t2: tags2
  #   t3: tags3

  _fromParams =
    perPage:        eeBootstrap?.perPage
    # categoryTitle:  null
    orderTitle:     null
    queryTokens:    []

  ## PRIVATE EXPORT DEFAULTS
  _data =
    reading:      false
    params:       _params
    fromParams:   angular.copy _fromParams
    products:     eeBootstrap?.products
    count:        eeBootstrap?.count
    page:         eeBootstrap?.page
    perPage:      eeBootstrap?.perPage
    took:         eeBootstrap?.took
    tagTree:      tagTree
    sortOrders:   sortOrders
    defaultSize:  eeBootstrap?.perPage || 48
    similarSize:  48
    searchInputs:
      minValue: 0
      maxValue: 300
      # data: eeProducts.data
      options:
        floor: 0
        ceil: 300
        step: 5
        hideLimitLabels: true
        translate: (value) -> if value < 300 then '$' + value else '>$' + value
        onEnd: (id, min, max) ->
          min ||= 0
          max ||= 300
          _setParam 'r', '' + min + '-' + max, { goTo: 'search'}
      # update: () ->
      #   # setSearchFromModal()
      #   $state.go 'search', $stateParams # , { notify: $state.current.name isnt 'search' }

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
    if $stateParams.q
      _tokenizeQuery $stateParams.q
      query.search = $stateParams.q
    if $stateParams.r is '0-0' then _setParam 'r', null
    if $stateParams.r
      query.min_price = parseInt($stateParams.r.split('-')[0]) * 100
      query.max_price = parseInt($stateParams.r.split('-')[1]) * 100
    if $stateParams.p     then query.page           = parseInt $stateParams.p
    if $stateParams.sz    then query.size           = parseInt $stateParams.sz
    if $stateParams.s     then query.order          = $stateParams.s
    if $stateParams.c     then query.category_ids   = [$stateParams.c]
    if $stateParams.coll  then query.collection_id  = parseInt $stateParams.coll
    if $stateParams.t     then query.tag            = $stateParams.t
    if $stateParams.t1    then query.tags1          = $stateParams.t1
    if $stateParams.t2    then query.tags2          = $stateParams.t2
    if $stateParams.t3    then query.tags3          = $stateParams.t3
    if $stateParams.handle then query.tags3         = $stateParams.handle # doorbusters
    _data.params = $stateParams
    _setFromParams()
    query

  _setFromParams = () ->
    _data.fromParams = angular.copy _fromParams
    if $stateParams.q? then _data.fromParams.queryTokens = _tokenizeQuery $stateParams.q
    if $stateParams.sz? then _data.fromParams.perPage = parseInt $stateParams.sz
    if $stateParams.s?
      for order in _data.sortOrders
        if order.order is $stateParams.s then _data.fromParams.orderTitle = order.title
    # if $stateParams.c?
    #   for category in categories
    #     if category.id is parseInt($stateParams.c) then _data.fromParams.categoryTitle = category.title
    if $stateParams.r?
      [min, max] = $stateParams.r.split('-').map((v) -> parseInt(v))
      _data.searchInputs.maxValue = if max > 0 and max < 300 then max else 300
      _data.searchInputs.minValue = if min > 0 and min < 300 and min <= max then min else 0
    else
      _data.searchInputs.maxValue = 300
      _data.searchInputs.minValue = 0

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
      _data[attr] = res[attr] for attr in ['count', 'page', 'perPage', 'took']
      _data.products  = res.rows
    .catch (err) -> _data.count = null
    .finally () -> _data.reading = false

  _searchLike = (product, opts) ->
    opts ||= {}
    _clearProducts()
    _clearParams() unless opts.silent?
    _setParam 'c', product.category_id
    _setParam 'q', product.title
    _setParam 'coll', null
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

  _pageResetNeeded = (toState, toParams, fromState, fromParams) ->
    switch toState.name
      when 'category'
        if toParams.id isnt fromParams.id then return true
    false

  ## Set initial values from URL
  _formQuery()

  ## MESSAGING
  $rootScope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
    if toState.name is 'category' then toParams.c = toParams.id
    if toState.name isnt 'search' then toParams.coll = null
    if toState.name is 'collection' or toState.name is 'sale'
      toParams.coll = toParams.id
      toParams.t1 = toParams.t2 = toParams.t3 = null
    if _pageResetNeeded(toState, toParams, fromState, fromParams) then toParams.p = null
    _setParams toParams
    switch toState.name
      when 'product', 'storefront', 'help' then return
      else _runQuery()

  $rootScope.$on 'product:navigate', (e, prod) -> _searchLike prod, { silent: true }

  # $rootScope.$on '$stateChangeSuccess', (e, toState, toParams, fromState, fromParams) ->
  #   _setPriceRangeToParams()

  ## EXPORTS
  data: _data
  fns:
    runQuery: _runQuery
    setParam: _setParam
    setParams: _setParams
    clearParams: _clearParams
    addToQuery: _addToQuery
    searchLike: _searchLike
