'use strict'

angular.module('store.home').controller 'favoriteCtrl', ($window, $state, $location, eeDefiner, eeFavorites, categories) ->

  favorite = this

  favorite.ee = eeDefiner.exports
  favorite.fns = eeFavorites.fns
  favorite.categories = categories
  favorite.absUrl = $location.absUrl().split('?')[0]

  eeFavorites.fns.setFavoritesCookieUnlessExists $state.params.obfuscated_id, $location.search().token

  eeFavorites.fns.defineSkuIdsAndProducts $state.params.obfuscated_id

  eeFavorites.fns.modalOrRedirect()

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
    body = "Hi!\n\nI'd like to share my list of Stylish Rustic favorites with you:" +
    '\n\n' + refUrl +
    '\n\n' + 'Enjoy!'
    mailto = 'mailto:?Subject=' + encodeURI(subject) + '&body=' + encodeURI(body).replace(/\&/g, '%26')
    $window.open mailto, '_blank'
    return

  return
