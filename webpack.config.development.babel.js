import merge from 'webpack-merge'
const common = require('./webpack.config.common.babel.js');

module.exports = merge(common, {
    mode: 'development',
    devtool: 'inline-source-map',
});
