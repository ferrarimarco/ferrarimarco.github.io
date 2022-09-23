#!/usr/bin/env sh

set -o errexit
set -o nounset

webpack --config webpack.config.production.babel.js

jekyll build --config _config.yml,_config.build.yml
