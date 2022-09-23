import HtmlWebpackPlugin from 'html-webpack-plugin'
import path from 'path'

module.exports = {
    entry: "./webpack/index.js",
    module: {
        rules: [
            {
                generator: {
                    // GitHub pages expects the name of this file to be CNAME
                    filename: '[name]'
                },
                test: /CNAME/,
                type: 'asset/resource'
            },
            {
                test: /\.(s(a|c)ss)$/,
                use: ['style-loader', 'css-loader', 'sass-loader']
            }
        ]
    },
    output: {
        clean: true,
        filename: "assets/javascript/[name].bundle.js",
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
