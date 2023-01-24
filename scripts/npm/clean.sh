#!/usr/bin/env sh

set -o errexit
set -o nounset

rm -rf \
  "./docs/"* \
  "./.tmp/"* \
  ./.publish \
  src/.jekyll-metadata
