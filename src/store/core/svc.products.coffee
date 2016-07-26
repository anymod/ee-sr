'use strict'

angular.module('store.core').factory 'eeProducts', ($rootScope, $q, $state, $stateParams, $location, $filter, eeBootstrap, eeBack, categories, stopWords) ->

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
    # inputs:   angular.copy _inputDefaults
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
  _setParam = (key, value) ->
    $location.search key, value
    $stateParams[key] = value

  _setParams = (obj) -> _setParam key, obj[key] for key in Object.keys(obj)

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
    # console.log '_formQuery', $stateParams, query
    query

  _clearParams = () -> _setParam(key, null) for key in Object.keys($stateParams)

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


  # _setPage = (p) ->
  #   if p then return _data.inputs.page = p
  #   for attr in ['search', 'range', 'order', 'page', 'category_id']
  #   if _lastQuery.search isnt _data.inputs.search or
  #   _lastQuery.range?.min isnt _data.inputs.range?.min or
  #   _lastQuery.range?.max isnt _data.inputs.range?.max or
  #   _lastQuery.order?.title isnt _data.inputs.order?.title or
  #   _lastQuery.category_id isnt _data.inputs.category_id
  #     _data.inputs.page = 1
  #
  # _setRange = (range) ->
  #   range ||= {}
  #   if (_data.inputs.range.min is range.min and _data.inputs.range.max is range.max) or (range.min is 0 and range.max is 0)
  #     _data.inputs.range.min = null
  #     _data.inputs.range.max = null
  #   else
  #     _data.inputs.range.min = range.min
  #     _data.inputs.range.max = range.max
  #
  # _setRangeByString = (rangeStr) ->
  #   # '0-50'
  #   return unless rangeStr?
  #   [min, max] = rangeStr.split('-').map((n) -> parseInt(n) * 100)
  #   _setRange { min: min, max: max }
  #
  # _setCategoryById = (category_id) ->
  #   if !category_id?
  #     _data.inputs.category_id = null
  #     _data.inputs.category.title = null
  #   for cat in _data.inputs.categories
  #     if cat.id is parseInt(category_id)
  #       _data.inputs.category_id = cat.id
  #       _data.inputs.categoryTitle = cat.title
  #
  # _setCollectionById = (collection_id) ->
  #   _data.inputs.collection_id = if collection_id? then parseInt(collection_id) else null
  #
  # _setSort = (order) ->
  #   if !order? then order = _data.inputs.orderArray[0]
  #   _data.inputs.order = order
  #
  # _setSortByString = (sortStr) ->
  #   # 'pa'
  #   return unless sortStr?
  #   for order in _data.inputs.orderArray
  #     if order.order is sortStr then return _data.inputs.order = order
  #
  # _addToken = (word) ->
  #   return if !word? or word.length < 1 or word is 'null'
  #   capitalized = word.charAt(0).toUpperCase() + word.toLowerCase().slice(1)
  #   return if _data.inputs.searchTokens.indexOf(capitalized) > -1 or (word.length is 1 and isNaN(word))
  #   return if stopWords.indexOf(word.toLowerCase()) > -1
  #   _data.inputs.searchTokens.push capitalized
  #
  # _tokenizeSearch = (term) ->
  #   term ||= ''
  #   term.replace(/[^a-zA-Z0-9-]|^-/gi, '-').replace(/-+/g,'-').toLowerCase()
  #   words = term.split(/[ ,]/g)
  #   _data.inputs.searchTokens = []
  #   _addToken word for word in words
  #   _data.inputs.search = _data.inputs.searchTokens.join(' ')
  #
  # _setSearch = (term) ->
  #   return unless term?
  #   _tokenizeSearch term
  #
  # _setUrlParams = () ->
  #   str = if _data.inputs.range?.min? or _data.inputs.range?.max? then [_data.inputs.range.min/100, _data.inputs.range.max/100].join('-') else null
  #   $stateParams.r = str
  #   $stateParams.p = _data.inputs.page
  #   $stateParams.c = _data.inputs.category_id
  #   $stateParams.s = _data.inputs.order?.order
  #   $stateParams.q = _data.inputs.search
  #   $stateParams.coll = _data.inputs.collection_id
  #   $location.search 'r', str
  #   $location.search 'p', _data.inputs.page
  #   $location.search 'c', _data.inputs.category_id
  #   $location.search 's', _data.inputs.order?.order
  #   $location.search 'q', _data.inputs.search
  #   $location.search 'coll', _data.inputs.collection_id
  #
  # _formQuery = () ->
  #   _setPage()
  #   _lastQuery = angular.copy _data.inputs
  #   query = {}
  #   query.size = _data.inputs.perPage
  #   if _data.inputs.page?         then query.page           = _data.inputs.page
  #   if _data.inputs.size?         then query.size           = _data.inputs.size
  #   if _data.inputs.search?       then query.search         = _data.inputs.search
  #   if _data.inputs.range.min?    then query.min_price      = _data.inputs.range.min
  #   if _data.inputs.range.max?    then query.max_price      = _data.inputs.range.max
  #   if _data.inputs.order.use?    then query.order          = _data.inputs.order.order
  #   if _data.inputs.category_id?  then query.category_ids   = [_data.inputs.category_id]
  #   if _data.inputs.collection_id? then query.collection_id  = _data.inputs.collection_id
  #   query

  _runQuery = () ->
    if _data.reading then return $q.when()
    _data.reading = true
    # _setUrlParams() unless skipUrl
    eeBack.fns.productsGET _formQuery()
    .then (res) ->
      { rows, count, took } = res
      _data.products  = rows
      _data.count     = count
      _data.took      = took
      # _data.inputs.searchLabel = _data.inputs.search
    .catch (err) -> _data.count = null
    .finally () -> _data.reading = false

  _search = (term) ->
    if $state.current.name is 'storefront' then $state.go 'search', $stateParams
    _clearProducts()
    _setSearch term
    _runQuery()

  _searchLike = (product) ->
    _clearProducts()
    _clearParams()
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

  _addToQuery = (term) ->
    return unless term?
    _setParam 'q', _data.params.q + ' ' + term

  _removeFromSearch = (token) ->
    index = _data.fromParams.queryTokens?.indexOf token
    if index > -1 then _data.fromParams.queryTokens.splice(index, 1)
    _search _data.fromParams.queryTokens.join(' ')

  ## SET INITIAL VALUES FROM URL
  _formQuery()
  # if eeBootstrap?
  #   # Order
  #   if eeBootstrap.order? then _setSort eeBootstrap.order
  #   # Categories
  #   if eeBootstrap.categorization_ids?
  #     cats = []
  #     for category in _inputDefaults.categories
  #       if eeBootstrap.categorization_ids.indexOf(category.id) > -1 then cats.push category
  #     _inputDefaults.categories = cats
  #   # Category
  #   if eeBootstrap.category?
  #     eeBootstrap.category = parseInt eeBootstrap.category
  #     _setCategoryById eeBootstrap.category
  #   # Collection
  #   if eeBootstrap.collection_id? then eeBootstrap.collection_id = parseInt eeBootstrap.collection_id
  #   # Price Range
  #   if eeBootstrap.range? then _setRangeByString eeBootstrap.range
  #   # Page
  #   if eeBootstrap.page? then _inputDefaults.page = parseInt eeBootstrap.page
  # # Query
  # _setSearch $stateParams.q
  # _lastQuery = angular.copy _data.inputs
  # _formQuery()

  ## MESSAGING
  # $rootScope.$on 'reset:page', () -> _setPage()
  $rootScope.$on 'product:navigate', (e, prod) -> _searchLike prod

  # $rootScope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
  #   _setSearch        toParams.q
  #   _setPage          toParams.p
  #   _setSortByString  toParams.s
  #   _setRangeByString toParams.r
  #   _setCategoryById  toParams.c
  #   _setCollectionById toParams.coll
  #   switch toState.name
  #     when 'storefront'
  #       _setSearch ''
  #       _setSort null
  #       _setRange null
  #       _setCategoryById null
  #       _setCollectionById null
  #     when 'category'
  #       _setCategoryById toParams.id
  #       _setCollectionById null
  #     when 'collection'
  #       _setCollectionById toParams.id
  #       _setCategoryById null
  #     when 'search'
  #       _setCollectionById null
  #     when 'sale'
  #       _setCollectionById toParams.id
  #       if fromState.name isnt 'sale'
  #         _setSearch ''
  #         _setSort null
  #         _setRange null
  #         _setCategoryById null
  #   switch toState.name
  #     when 'search', 'category', 'collection', 'sale' then _runQuery(true)
  #   return

  ## EXPORTS
  data: _data
  fns:
    runQuery: _runQuery
    setParam: _setParam
    setParams: _setParams
    clearParams: _clearParams
    # runQuery: _runQuery
    # search: _search
    addToQuery: _addToQuery
    searchLike: _searchLike
    # removeFromSearch: _removeFromSearch
    # setCategory: (category) ->
    #   _clearProducts()
    #   _setCategoryById category.id
    #   _runQuery()
    # setOrder: (order) ->
    #   _clearProducts()
    #   _setSort order
    #   _runQuery()
    # setRange: (range) ->
    #   _clearProducts()
    #   _setRange range
    #   _runQuery()
