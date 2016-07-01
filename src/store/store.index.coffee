'use strict'

angular.module 'eeStore', [
  # vendor
  'ngCookies'
  'ngAnimate'
  'ui.router'
  'ui.bootstrap'
  # 'ngSanitize'
  'angulartics'
  'angulartics.google.analytics'

  # core
  'app.core'

  # store
  'store.core'
  'store.home'
  'store.collections'
  'store.sale'
  'store.categories'
  'store.product'
  'store.cart'
  'store.checkout'
  'store.order'
  'store.help'
  'store.search'
  'store.favorites'

  # custom
  'ee-storefront-announcement'
  'ee-storefront-header'
  'ee-storefront-scroller'
  'ee-storefront-brand'
  'ee-scroll-to-top'
  'ee-scroll-show'
  'ee-collection-nav'
  'ee-collection-for-store'
  'ee-product-for-store'
  'ee-product-card'
  'ee-product-images'
  'ee-search-sort'
  'ee-empty-message'
  'ee-loading'
  'ee-signup'
  'ee-signup-message'
  'ee-favorites-signup'
  'ee-favorites-heart'
  'ee-image-fadein'
  'ee-products-list'
  'ee-paypal-button'
  # 'ee.templates' # commented out during build step for inline templates
]
