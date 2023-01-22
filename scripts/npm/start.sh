#!/usr/bin/env sh

set -o errexit
set -o nounset

ENVIRONMENT="${1}"

npm run build -- "${ENVIRONMENT}"

echo "Serving for the ${ENVIRONMENT} environment"

webpack serve --config "webpack.config.${ENVIRONMENT}.babel.js"
