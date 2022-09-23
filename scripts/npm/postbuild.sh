#!/usr/bin/env sh

set -o errexit
set -o nounset

jekyll doctor

rm -rf ./.tmp/jekyll-preprocessed-src/.jekyll-cache
