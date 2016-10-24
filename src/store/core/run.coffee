'use strict'

angular.module('store.core').run ($rootScope, $cookies, $location, $window, eeModal, eeCoupon, eeAnalytics, eeCart) ->

  ## SETUP
  $rootScope.isStore = true

  win = angular.element($window)

  _openSignupModal = () ->
    if $cookies.get('offered') or $cookies.get('coupon') then return false
    $cookies.put 'offered', (eeAnalytics.data.pageDepth || true)
    eeModal.fns.open 'offer'
    return true

  _openCartOfferModal = () ->
    if $cookies.get('offered-cart') or $cookies.get('coupon') then return false
    if $cookies.get('cart')
      $cookies.put 'offered-cart', (eeAnalytics.data.pageDepth || true)
      eeModal.fns.open 'offer_cart'
      return true

  $rootScope.eeMouseleave = () ->
    _openCartOfferModal() || _openSignupModal()

  if !$cookies.get('offered')?
    win.bind 'touchstart', (e) ->
      win.unbind 'touchstart'
      win.bind 'scroll', (e) ->
        if $window.pageYOffset > 1999
          _openSignupModal()
          win.unbind 'scroll'

  if $cookies.get('coupon')? then eeCoupon.fns.defineCoupon()

  ## MESSAGING
  $rootScope.$on 'keen:addEvent', (e, title) ->
    eeAnalytics.fns.addKeenEvent title

  $rootScope.$on 'favorites:toggle', (e, favorited, sku_id) ->
    eeAnalytics.fns.addKeenEvent 'favorites', { toggledOn: favorited, toggledOff: !favorited, sku_id: sku_id }

  # # Broadcast page reset on stateChangeStart and stateChangeSuccess to remove page param
  $rootScope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
    if eeAnalytics.data.pageDepth > 1 and (toState.name isnt fromState.name or toParams.id isnt fromParams.id) then $rootScope.$broadcast 'reset:page'

  $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
    eeAnalytics.data.pageDepth++

    if eeAnalytics.data.pageDepth > 1 and (toState.name isnt fromState.name or toParams.id isnt fromParams.id) then $rootScope.$broadcast 'reset:page'

    if !$cookies.get('_ee')
      d = new Date()
      str = '' + ('' + d.getFullYear()).slice(-2) + ('0' + d.getUTCMonth()).slice(-2) + ('0' + d.getUTCDay()).slice(-2) + '.' + Math.random().toString().substr(2,8)
      $cookies.put '_ee', str
    if $location.search().s is 't'
      $cookies.put '_eeself', true
      $location.search 's', null

    eeAnalytics.fns.addKeenEvent 'store', {
      toState:    toState?.name
      toParams:   toParams
      fromState:  fromState?.name
      fromParams: fromParams
    }

    return

  return
