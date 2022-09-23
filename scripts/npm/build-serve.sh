#!/usr/bin/env sh

set -o errexit
set -o nounset

npm run build

webpack serve --config webpack.config.production.babel.js
