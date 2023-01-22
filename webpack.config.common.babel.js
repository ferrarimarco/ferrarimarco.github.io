import CopyPlugin from 'copy-webpack-plugin'
import HtmlWebpackPlugin from 'html-webpack-plugin'
import path from 'path'

module.exports = {
    devServer: {
        static: {
            directory: './docs',
        },
    },
    entry: "./webpack/index.js",
    module: {
        rules: [
            {
                generator: {
                    filename: 'assets/images/[name]'
                },
                test: /\.(png|ico)$/i,
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
        new CopyPlugin({
            patterns: [
                {
                    from: "src",
                    globOptions: {
                        ignore: ["**/_includes/head.html", "**/*.scss", "**/favicon.ico"],
                    },
                    to: "./"
                },
            ],
        }),
        // Inject webpack-managed assets in the head
        new HtmlWebpackPlugin({
            favicon: "./src/assets/favicon.ico",
            filename: "./_includes/head.html",
            hash: true,
            template: "./src/_includes/head.html"
        })
    ]
};
