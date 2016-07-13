Sequelize     = require 'sequelize'
sequelize     = require '../config/sequelize/setup'
elasticsearch = require '../config/elasticsearch/setup'
Promise       = require 'bluebird'
_             = require 'lodash'
url           = require 'url'
constants     = require '../server.constants'
utils         = require './utils'

Customization = require './customization'
Collection    = require './collection'
Sku           = require './sku'

Shared = require '../copied-from-ee-back/shared'

Product = sequelize.define 'Product',
  # TODO DRY up this code between ee-back
  title:              type: Sequelize.STRING,   allowNull: false, validate: len: [3,140]
  content:            type: Sequelize.TEXT,     validate: len: [0,5000]
  external_identity:  type: Sequelize.STRING,   allowNull: false
  image:              type: Sequelize.STRING,   allowNull: false
  additional_images:  type: Sequelize.ARRAY(Sequelize.STRING)
  category_id:        type: Sequelize.INTEGER
  subcategory_id:     type: Sequelize.INTEGER
,
  underscored: true

  classMethods:

    findById: Shared.Product.findById
    findAllByIds: Shared.Product.findAllByIds
    findCompleteById: Shared.Product.findCompleteById
    search: Shared.Product.search
    addCustomizationsFor: Shared.Product.addCustomizationsFor

    findAllByCollection: (user, opts) ->
      Collection.findById opts.collection_id, user.id
      .then (rows) -> Shared.Collection.formattedResponse rows[0], user, opts

Product.elasticsearch_findall_attrs = [
  'id'
  'title'
  'image'
  'category_id'
  'skus'
  # 'msrps'
]

module.exports = Product
