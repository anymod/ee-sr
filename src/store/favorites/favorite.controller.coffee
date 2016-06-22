'use strict'

angular.module('store.home').controller 'favoriteCtrl', ($window, $state, $location, eeDefiner, eeFavorites) ->

  favorite = this

  favorite.ee = eeDefiner.exports
  favorite.fns = eeFavorites.fns
  favorite.absUrl = $location.absUrl()

  eeFavorites.fns.setFavoritesCookieUnlessExists $state.params.obfuscated_id
  eeFavorites.fns.defineProducts $state.params.obfuscated_id

  # eeFavorites.fns.defineSkuIds()
  # eeFavorites.fns.defineProducts()

  favorite.copiedToClipboard = false
  favorite.copyToClipboard = (toCopy) ->
    body = angular.element $window.document.body
    favorite.copiedToClipboard = false
    temp = angular.element '<input>'
    body.append temp
    temp.val toCopy
    temp[0].select()
    try
      successful = document.execCommand('copy')
      if !successful then throw successful
      favorite.copiedToClipboard = true
    catch err
      window.prompt 'Copy to clipboard: Ctrl+C or Command+C', toCopy
    temp.remove()
    return

  favorite.openEmail = (refUrl) ->
    subject = 'My favorites on Stylish Rustic'
    body = "Hi!\n\nI've created a list of favorites on Stylish Rustic and I thought you might be interested in seeing them." +
    "\n\nHere’s my link: " + refUrl
    mailto = 'mailto:?Subject=' + encodeURI(subject) + '&body=' + encodeURI(body).replace(/\&/g, '%26')
    $window.open mailto, '_blank'
    return

  return
