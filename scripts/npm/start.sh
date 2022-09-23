#!/usr/bin/env sh

set -o errexit
set -o nounset

webpack serve --config webpack.config.development.babel.js
