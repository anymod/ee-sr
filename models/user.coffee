Promise   = require 'bluebird'
_         = require 'lodash'
url       = require 'url'
sequelize = require '../config/sequelize/setup'
constants = require '../server.constants'
utils     = require './utils'

Collection = require './collection'
Shared    = require '../copied-from-ee-back/shared'

### IMPORTANT ###
# Users, Collections, and Orders should use
# 'deleted_at IS NULL' as part of query

User =

  storeByDomain: (host) ->
    sequelize.query 'SELECT id, tr_uuid, username, store_name, logo, storefront_meta, colors, design_band_image, home_carousel, home_arranged, categorization_ids, pricing, alpha, beta FROM "Users" WHERE domain = ? AND deleted_at IS NULL', { type: sequelize.QueryTypes.SELECT, replacements: [host] }

  storeByUsername: (username) ->
    sequelize.query 'SELECT id, tr_uuid, username, store_name, logo, storefront_meta, colors, design_band_image, home_carousel, home_arranged, categorization_ids, pricing, alpha, beta FROM "Users" WHERE username = ? AND deleted_at IS NULL', { type: sequelize.QueryTypes.SELECT, replacements: [username] }

  findByHost: (host) ->
    host  = host.replace 'www.', ''
    searchTerm  = host
    queryUser   = User.storeByDomain
    if process.env.NODE_ENV isnt 'production' or host.indexOf('eeosk.com') > -1 or host.indexOf('herokuapp.com') > -1 or host.indexOf('.demoseller.com') > -1
      username = 'stylishrustic' # '' # 'houstylish'
      # if host.indexOf('herokuapp.com') > -1 then username = 'stylishrustic' # 'demoseller'
      # if host.indexOf('eeosk.com') > -1 or host.indexOf('.demoseller.com') > -1 then username = host.split('.')[0]
      searchTerm  = username
      queryUser   = User.storeByUsername
    queryUser searchTerm

  defineStorefront: (host, bootstrap) ->
    User.findByHost host
    .then (data) ->
      user = data[0]
      Shared.User.addAccentColors user
      Shared.User.trimDesignBand user, 1200, 50, 'fill'
      utils.assignBootstrap bootstrap, user

  defineHomepage: (bootstrap) ->
    bootstrap.home_carousel ||= []
    bootstrap.home_arranged ||= []
    bootstrap.home_featured ||= []
    bootstrap.home_recommended ||= []
    bootstrap.home_subtags ||= {}
    Collection.findHomeCarousel bootstrap.home_carousel.join(','), { id: bootstrap.id, pricing: bootstrap.pricing, alpha: bootstrap.alpha }
    .then (collections) ->
      bootstrap.home_carousel = collections
      Collection.findHomeArranged bootstrap.home_arranged.join(','), { id: bootstrap.id, pricing: bootstrap.pricing, alpha: bootstrap.alpha }
    .then (collections) ->
      bootstrap.home_arranged = collections
      # Doorbusters
      featured = '6211,6335,7590,6242,6655,7597,6251,6072'
      # featured = '6291,4516,717,2182,5059,1890,2229,5599,6597,6818'
      Shared.Product.findHomeFeatured featured, { id: bootstrap.id, pricing: bootstrap.pricing, alpha: bootstrap.alpha }
    .then (products) ->
      bootstrap.home_featured = products
      # Doorbusters
      recommended = '222,4770,5619,5599,5022,2250,4909,4778,6412,7517,6688,6220,6240,7570,6097,6089,6305,3742'
      # recommended = '665,1373,2028,1207,2019,2047,2029,1670,392,1624,2024,1392,558,2040,722,717,1742,2118,805,739,2123,762,2137,761,2168,2166,796,2231,2220,2258,2275,820,2395'
      Shared.Product.findHomeRecommended recommended, { id: bootstrap.id, pricing: bootstrap.pricing, alpha: bootstrap.alpha }
    .then (products) ->
      bootstrap.home_recommended = products
      Shared.Product.findSubtags { id: bootstrap.id, pricing: bootstrap.pricing, alpha: bootstrap.alpha }
    .then (subtags) ->
      bootstrap.home_subtags = subtags
      # console.log 'bootstrap', bootstrap
      bootstrap

  setCollectionMetaImages: (bootstrap) ->
    Collection.metaImagesFor bootstrap.id
    .then (images) ->
      if images and images.length > 0 then bootstrap.images = utils.makeMetaImages images

  defineSitemap: (protocol, host, bootstrap) ->
    baseLoc = protocol + '://' + host
    lastmod = utils.yyyymmdd()
    entries = [
      { loc: baseLoc, lastmod: lastmod, changefreq: 'weekly', priority: '1.0' }
      # { loc: baseLoc + '/collections', lastmod: lastmod, changefreq: 'weekly', priority: '0.9' }
      { loc: baseLoc + '/help', lastmod: lastmod, changefreq: 'monthly', priority: '0.8' }
      { loc: baseLoc + '/search', lastmod: lastmod, changefreq: 'monthly', priority: '0.6' }
    ]
    User.findByHost host
    .then (data) ->
      user = data[0]
      if user.storefront_meta.about?.headline then entries.push { loc: baseLoc + '/about', lastmod: lastmod, changefreq: 'monthly', priority: '0.7' }
      Collection.findAll user.id
    .then (collections) ->
      for collection in collections
        entries.push { loc: baseLoc + '/collections/' + collection.id + '/', lastmod: lastmod, changefreq: 'weekly', priority: '0.9' }
      entries


module.exports = User
