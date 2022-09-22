import path from 'path'

module.exports = {
    entry: "./webpack/index.js",
    mode: 'production',
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'docs'),
    },
};
