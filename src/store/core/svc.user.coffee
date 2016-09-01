'use strict'

angular.module('store.core').factory 'eeUser', ($location, eeBootstrap, eeBack, categories) ->

  ## SETUP
  _data =
    reading: false
    user:
      current_host: $location.host() # For Terms and Privacy pages
    categories: categories

  # _setFeatured = () ->
  #   # Choose 6 products for featured section
  #   # TODO move this to server-side
  #   _data.user.home_featured = []
  #   return unless _data.user.home_arranged?.length > 0 and _data.user.home_arranged[0].products?.length > 0
  #   console.log _data.user.home_arranged[0].products.slice(0,6)
  #   for product in _data.user.home_arranged[0].products.slice(0,6)
  #     _data.user.home_featured.push product
  #
  # _setRecommended = () ->
  #   # Group products in threes for recommended carousel
  #   # TODO move this to server-side
  #   _data.user.home_recommended = []
  #   return unless _data.user.home_arranged?.length > 0 and _data.user.home_arranged[2].products?.length > 0
  #   i = 0
  #   while i < _data.user.home_arranged[2].products.length && i <= 22
  #     _data.user.home_recommended.push _data.user.home_arranged[2].products.slice(i, i+3)
  #     i += 3

  if eeBootstrap
    _data.user[attr] = eeBootstrap[attr] for attr in ['username', 'storefront_meta', 'logo', 'categorization_ids', 'home_carousel', 'home_arranged', 'home_featured', 'home_recommended', 'home_subtags', 'colors', 'design_band_image', 'store_name', 'alpha', 'beta']
    # _setFeatured()
    # _setRecommended()

  ## PRIVATE FUNCTIONS
  _getUser = () ->
    return if _data.reading
    _data.reading = true
    _data.user.home_carousel = []
    _data.user.home_arranged = []
    eeBack.fns.userGET()
    .then (user) ->
      _data.user[attr] = user[attr] for attr in Object.keys(user)
      # _setFeatured()
      # _setRecommended()
    .finally () -> _data.reading = false

  ## EXPORTS
  data: _data
  fns:
    getUser: _getUser
