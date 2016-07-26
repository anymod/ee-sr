'use strict'

angular.module('store.core').run ($rootScope, $cookies, $location, $window, eeModal, eeAnalytics) ->

  ## SETUP
  $rootScope.isStore = true

  if !$cookies.get('offered')?
    $rootScope.openSignupModal = () ->
      $cookies.put 'offered', (eeAnalytics.data.pageDepth || true)
      eeModal.fns.open 'offer'
      $rootScope.openSignupModal = () -> false

    win = angular.element($window)
    win.bind 'touchstart', (e) ->
      win.unbind 'touchstart'
      win.bind 'scroll', (e) ->
        if $window.pageYOffset > 1999
          $rootScope.openSignupModal()
          win.unbind 'scroll'

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
