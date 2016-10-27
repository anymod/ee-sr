'use strict'

angular.module('store.signup').controller 'signupCtrl', (eeDefiner, eeUser) ->

  signup = this

  signup.ee = eeDefiner.exports

  eeUser.fns.getUser()

  return
