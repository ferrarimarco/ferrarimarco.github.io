import HtmlWebpackPlugin from 'html-webpack-plugin'
import path from 'path'

module.exports = {
    entry: "./webpack/index.js",
    output: {
        clean: true,
        filename: "bundle.js",
        path: path.resolve(__dirname, ".tmp/jekyll-preprocessed-src"),
    },
    plugins: [
        new HtmlWebpackPlugin({
            filename: "./_includes/head.html",
            hash: true,
            template: "./src/_includes/head.html"
        })
    ]
};
