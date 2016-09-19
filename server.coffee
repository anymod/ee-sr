switch process.env.NODE_ENV
  when 'production'
    require 'newrelic'
  when 'test'
    process.env.PORT = 4444
  else
    process.env.NODE_ENV = 'development'
    process.env.PORT = 4000

express       = require 'express'
morgan        = require 'morgan'
path          = require 'path'
serveStatic   = require 'serve-static'
cookieParser  = require 'cookie-parser'
ejs           = require 'ejs'
compression   = require 'compression'
_             = require 'lodash'
constants     = require './server.constants'
utils         = require './models/utils'

User          = require './models/user'
Product       = require './models/product'
Collection    = require './models/collection'
Sku           = require './models/sku'
Cart          = require './models/cart'

app = express()
app.use compression()

app.set 'view engine', 'ejs'
app.set 'views', path.join __dirname, 'dist'

if process.env.NODE_ENV is 'production' then app.use morgan 'common' else app.use morgan 'dev'

app.use serveStatic(path.join __dirname, 'dist')
app.use cookieParser()

cartCookie = (req, res, next) ->
  if req.cookies and req.cookies.cart
    [ee, cart_id, uuid] = req.cookies.cart.split('.')
    if !cart_id or !uuid then return next()
    Cart.findByIdAndUuid cart_id, uuid
    .then (data) -> req.cart = data[0]
    .catch (err) -> console.log 'Error in cartCookie', err
    .finally () -> next()
  else
    next()

app.use cartCookie

# HOME
app.get ['/', '/discounts/:uuid'], (req, res, next) ->
  { bootstrap, host, path } = utils.setup req
  User.defineStorefront host, bootstrap
  .then () -> User.defineHomepage bootstrap
  # TODO finish new meta images
  .then () -> User.setCollectionMetaImages bootstrap
  .then () ->
    bootstrap.stringified = utils.stringify bootstrap
    res.render 'store.ejs', { bootstrap: bootstrap }
  .catch (err) ->
    # TODO add better error pages
    console.error 'error in HOME', err
    res.send 'Not found'

# PRODUCT
app.get '/products/:id/:title*?', (req, res, next) ->
  { bootstrap, host, path } = utils.setup req
  User.defineStorefront host, bootstrap
  .then () ->
    Product.findCompleteById req.params.id, { id: bootstrap.id, pricing: bootstrap.pricing, alpha: bootstrap.alpha }
  .then (product) ->
    bootstrap.product     = product
    bootstrap.title       = bootstrap.product.title
    bootstrap.images      = utils.makeMetaImages([ bootstrap.product?.image ])
    bootstrap.description = bootstrap.product.content
    bootstrap.stringified = utils.stringify bootstrap
    res.render 'store.ejs', { bootstrap: bootstrap }
  .catch (err) ->
    console.error 'error in PRODUCTS', err
    res.redirect '/'

searchAndRespond = (res, bootstrap) ->
  new Promise (resolve, reject) ->
    if bootstrap.collection_id > 0
      Collection.findById bootstrap.collection_id, bootstrap.id
      .then (data) ->
        bootstrap.collection = data[0]
        resolve true
    else
      resolve false
  .then () ->
    opts = utils.searchOpts bootstrap
    Product.search { id: bootstrap.id, pricing: bootstrap.pricing, alpha: bootstrap.alpha }, opts
  .then (data) ->
    { rows, count, page, perPage } = data
    bootstrap.products    = rows || []
    bootstrap.count       = count
    bootstrap.page        = page
    bootstrap.perPage     = perPage
    bootstrap.images      = utils.makeMetaImages(_.map(bootstrap.products.slice(0,3), 'image'))
    bootstrap.stringified = utils.stringify bootstrap
    res.render 'store.ejs', { bootstrap: bootstrap }

# SEARCH, CATEGORY, COLLECTION, SALE
app.get ['/search', '/categories/:id/:title*?', '/collections/:id/:title*?', '/sale/:id/:title*?'], (req, res, next) ->
  { bootstrap, host, path } = utils.setup req
  User.defineStorefront host, bootstrap
  .then () -> searchAndRespond res, bootstrap
  .catch (err) ->
    console.error 'error in SEARCH', err
    res.redirect '/'

# CART
app.get '/cart', (req, res, next) ->
  { bootstrap, host, path } = utils.setup req
  User.defineStorefront host, bootstrap
  .then () ->
    if req.cart and req.cart.quantity_array and req.cart.quantity_array.length > 0
      sku_ids = _.map req.cart.quantity_array, 'sku_id'
      Sku.forCart sku_ids.join(','), bootstrap.id
      .then (data) -> bootstrap.cart.skus = data
      .finally () ->
        bootstrap.stringified = utils.stringify bootstrap
        res.render 'store.ejs', { bootstrap: bootstrap }
    else
      bootstrap.stringified = utils.stringify bootstrap
      res.render 'store.ejs', { bootstrap: bootstrap }
  .catch (err) ->
    console.error 'error in CART', err
    res.redirect '/'

# SITEMAP
app.get ['/sitemap', '/sitemap.xml'], (req, res, next) ->
  { bootstrap, protocol, host, path } = utils.setup req
  User.defineSitemap protocol, host, bootstrap
  .then (entries) ->
    res.setHeader 'content-type', 'text/xml'
    res.render 'sitemap.ejs', { entries: entries }
  .catch (err) ->
    console.error 'error in SITEMAP', err
    res.redirect '/'

# LEGACY REDIRECTS
app.get ['/selections/:id/:title', '/shop', '/shop/:title', '/collections'], (req, res, next) ->
  res.redirect '/'

# FAVICON
app.get '/favicon.ico', (req, res, next) ->
  res.send 'Not found'

# CATCHALL (about, help, terms, privacy, favorites)
app.get '/*', (req, res, next) ->
  { bootstrap, host, path } = utils.setup req
  User.defineStorefront host, bootstrap
  .then () ->
    bootstrap.stringified = utils.stringify bootstrap
    res.render 'store.ejs', { bootstrap: bootstrap }
  .catch (err) ->
    console.error 'error in /*', err
    res.redirect '/'

app.listen process.env.PORT, ->
  console.log 'Store app listening on port ' + process.env.PORT
  return
