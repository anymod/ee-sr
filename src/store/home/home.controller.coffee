'use strict'

angular.module('store.home').controller 'homeCtrl', (eeDefiner, eeUser, eeAnalytics) ->

  home = this

  home.ee = eeDefiner.exports
  home.subtagActive = 0

  # if eeAnalytics.data.pageDepth > 1 then eeUser.fns.getUser()

  home.sidebarProducts = [
    {
      id: 5599
      title: 'Fine Mod Imports Clear Arm Chair, Clear'
      image: 'https://res.cloudinary.com/eeosk/image/upload/v1477320552/hawaii_chic_sunsna.jpg'
    },
    {
      id: 2182
      title: 'Antique Silver Finish Glass Candle Holders, Set of 2'
      image: 'https://res.cloudinary.com/eeosk/image/upload/v1477446398/Glass-Candlestick-Set-2.jpg'
    },
    {
      id: 4806
      title: 'Jingren Serving Tray, Wood and Metal'
      image: 'https://res.cloudinary.com/eeosk/image/upload/v1477589062/4806-addition-1.jpg'
    },
    {
      id: 6656
      title: 'Alliance Dining Table Natural Fir'
      image: 'https://res.cloudinary.com/eeosk/image/upload/v1477506429/alliance-dining-table.jpg'
    },
    {
      id: 599
      title: '24" Cushion Saddle Seat Stool, Black Faux Leather, Wood Legs'
      image: 'https://res.cloudinary.com/eeosk/image/upload/v1477322705/Irving_2BKitchen_2BIsland_dqj3u1.jpg'
    },
    # {
    #   id: ''
    #   title: ''
    #   image: ''
    # },
    # {
    #   id: 820
    #   title: 'Peacock Figurine Set'
    #   image: 'https://res.cloudinary.com/eeosk/image/upload/v1477431647/Peacock-Figurine-Set-1.jpg'
    # },
    {
      id: 6315
      title: 'Eames Inspired Coffee Table'
      image: 'https://res.cloudinary.com/eeosk/image/upload/v1477322411/eames-plywood-coffee-table_ie6ccf.jpg'
    }
  ]

  return
