import path from 'path'

module.exports = {
    entry: "./webpack/index.js",
    mode: 'production',
    output: {
        clean: true,
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'docs'),
    },
};
