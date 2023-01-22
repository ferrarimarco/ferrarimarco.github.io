#!/usr/bin/env sh

set -o errexit
set -o nounset

ENVIRONMENT="${1}"

echo "Building for the ${ENVIRONMENT} environment"

webpack --config "webpack.config.${ENVIRONMENT}.babel.js"

jekyll build --config _config.yml,_config.build.yml
