'use strict'

angular.module('store.guests').controller 'guestsCtrl', (eeBack) ->

  guests = this

  guests.quotes = []

  eeBack.fns.productsGET { collection_id: 13476 }
  .then (res) ->
    for quote in guests.quotes
      for product in res.rows
        if quote.product_id is product.id
          quote.product = product

  guests.quotes = [
    {
      product_id: 1937
      text: 'I never get tired of these lounge chairs! The color is perfect and they are affordable.'
    },
    {
      product_id: 2252
      text: 'This mirror might be one of my favorite finds! It\'s substantial in size and it\'s a great deal. Every room needs a statement mirror.'
    },
    {
      product_id: 6030
      text: 'Glass tables are the perfect way to lighten up a space and the unique shape of this one is so fun!'
    },
    {
      product_id: 4680
      text: 'The beaded stool would make a great end table or extra seat. The shiny, ombre effect is beautiful!'
    },
    {
      product_id: 717
      text: 'I\'m a magazine hoarder so a good holder is always something I\'m on the lookout for.'
    },
    {
      product_id: 4781
      text: 'Bud vases are an easy way to add small flower arrangements in your home. I love the modern look of these.'
    },
    {
      product_id: 6555
      text: 'Faux flowers these days can be stylish and this arrangement is no exception. If you don\'t have the DIY notion this one is definitely a great option!'
    },
    {
      product_id: 6679
      text: 'Amazing – is really all I can say about this pendant light. Swoon.'
    },
    {
      product_id: 6656
      text: 'I love the style and the rich wood of this table.'
    },
    {
      product_id: 6259
      text: 'Although a bit pricey, these chairs stopped me in my tracks and they come in a set of two!'
    },
    {
      product_id: 7463
      text: 'Outdoor spaces are one of my favorites to decorate and a comfy sectional is a must.'
    },
    {
      product_id: 6646
      text: 'This dresser is so unique and I love the color of the wood.'
    },
    {
      product_id: 4934
      text: 'I\'m a sucker for a good clam shell bowl and this one is a great size and shape.'
    },
    {
      product_id: 6818
      text: 'Moscow mule mugs are a bar cart staple so I always snag them up when I can good deals.'
    },
    {
      product_id: 6236
      text: 'Oh my, this is one pretty coffee table! The rose gold is so pretty and 100% on trend!'
    },
    {
      product_id: 5996
      text: 'This pouf is the perfect boho touch for any space. I love the colors and pattern!'
    },
    {
      product_id: 5924
      text: 'This cushioned ottoman is classic and sleek and would work great in a man cave or masculine-style living room.'
    }
  ]

  return
