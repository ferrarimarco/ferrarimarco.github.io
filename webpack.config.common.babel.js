import CopyPlugin from 'copy-webpack-plugin'
import HtmlWebpackPlugin from 'html-webpack-plugin'
import path from 'path'

module.exports = {
  devServer: {
    // allowedHosts: 'auto',
    client: {
      logging: 'info',
      overlay: true,
      progress: true,
      reconnect: true
    },
    port: 3000,
    static: {
      directory: './docs'
    }
  },
  entry: './webpack/index.js',
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
        use: [
          // Creates `style` nodes from JS strings
          'style-loader',
          // Translates CSS into CommonJS
          'css-loader',
          // Compiles Sass to CSS
          'sass-loader'
        ]
      }
    ]
  },
  output: {
    clean: true,
    filename: 'assets/javascript/[name].bundle.js',
    path: path.resolve(__dirname, '.tmp/jekyll-preprocessed-src')
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        {
          from: 'src',
          globOptions: {
            ignore: ['**/_includes/head.html', '**/*.scss', '**/favicon.ico', '**/.gitignore']
          },
          to: './'
        }
      ]
    }),
    // Inject webpack-managed assets in the head
    new HtmlWebpackPlugin({
      favicon: './src/assets/favicon.ico',
      filename: './_includes/head.html',
      hash: true,
      template: './src/_includes/head.html'
    })
  ]
}
