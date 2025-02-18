#! /usr/bin/env sh

FLUTTER_VERSION="$(head -n1 Dockerfile | awk -F ':' '{ print $2 }' | awk -F '-' '{ print $1 }')"

sed -i 's/FLUTTER_VERSION: .*/FLUTTER_VERSION: '"$FLUTTER_VERSION"'/g' .gitlab-ci.yml
echo "$FLUTTER_VERSION" > flutter_version
