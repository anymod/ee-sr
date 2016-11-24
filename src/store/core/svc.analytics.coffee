'use strict'

angular.module('store.core').factory 'eeAnalytics', ($window, $cookies, $location, eeBootstrap) ->

  ## SETUP
  # Keen.js
  _keen = new Keen
    projectId: '565c9b27c2266c0bb36521db',
    writeKey: 'a36f4230d8a77258c853d2bcf59509edc5ae16b868a6dbd8d6515b9600086dbca7d5d674c9307314072520c35f462b79132c2a1654406bdf123aba2e8b1e880bd919482c04dd4ce9801b5865f4bc95d72fbe20769bc238e1e6e453ab244f9243cf47278e645b2a79398b86d7072cb75c'

  _signupTextArray = [
    'Sign up to know when the doorbuster sale starts'
    # 'Receive 10% off when you join our mailing list'
    # 'Follow us and receive 10% off your first order'

    # 'Follow us for sales and exclusive offers'
    # 'Follow us for decor ideas'
    # 'Stay in the know on the latest home furnishings'
  ]

  ## PRIVATE EXPORT DEFAULTS
  _data =
    pageDepth: 0
    refererDomain: if eeBootstrap.referer then new URL(eeBootstrap.referer).hostname else null
    signupText: _signupTextArray[Math.floor(Math.random() * _signupTextArray.length)]

  if _data.refererDomain
    if _data.refererDomain.indexOf('google.') > -1 then _data.refererDomain = 'Google'
    else if _data.refererDomain.indexOf('facebook.') > -1 or _data.refererDomain.indexOf('fb.me') > -1 then _data.refererDomain = 'Facebook'
    else if _data.refererDomain.indexOf('pinterest.') > -1 then _data.refererDomain = 'Pinterest'
    else if _data.refererDomain.indexOf('twitter.') > -1 or _data.refererDomain is 't.co' then _data.refererDomain = 'Twitter'
    else if _data.refererDomain.indexOf('instagram.') > -1 then _data.refererDomain = 'Instagram'

  ## PRIVATE FUNCTIONS
  _getKeenObject = () -> {
    user:           eeBootstrap.tr_uuid
    referer:        eeBootstrap.referer
    refererDomain:  _data.refererDomain
    url:            $location.absUrl()
    host:           $location.host()
    path:           $location.path()
    pageDepth:      _data.pageDepth
    signupText:     _data.signupText
    signupModalDepth: $cookies.get('offered')
    windowWidth:    $window.innerWidth
    self:           !!$cookies.get('_eeself')
    _ee:            $cookies.get('_ee')
    _ga:            $cookies.get('_ga')
    _gat:           $cookies.get('_gat')
  }

  _addKeenEvent = (title, data) ->
    return if !title? or $location.host() is 'localhost' or $location.host().indexOf('herokuapp') > -1
    keenObj = _getKeenObject()
    if data?
      keenObj[key] = data[key] for key in Object.keys(data)
    _keen.addEvent title, keenObj

  ## EXPORTS
  data: _data
  fns:
    addKeenEvent: _addKeenEvent
