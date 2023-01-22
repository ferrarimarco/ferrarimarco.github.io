#!/usr/bin/env sh

set -o errexit
set -o nounset

npm run clean

jekyll doctor
