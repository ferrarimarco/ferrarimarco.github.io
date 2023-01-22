import merge from 'webpack-merge'
const common = require('./webpack.config.common.babel.js')

module.exports = merge(common, {
  devtool: 'source-map',
  mode: 'production'
})
