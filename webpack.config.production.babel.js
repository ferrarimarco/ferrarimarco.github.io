const { merge } = require('webpack-merge');
const common = require('./webpack.config.common.babel.js');

module.exports = merge(common, {
    mode: 'production',
});
