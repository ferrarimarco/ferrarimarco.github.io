#!/usr/bin/env sh

set -o errexit
set -o nounset

npm run build

webpack serve --open --config webpack.config.production.babel.js
