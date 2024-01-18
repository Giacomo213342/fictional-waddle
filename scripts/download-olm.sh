#!/usr/bin/env bash

set -e

OLM_DEST="web/js/olm"

if [ -d "$OLM_DEST" ]; then
  rm -r "$OLM_DEST"
fi

OLM_VERSION=$(yq -r .packages.flutter_olm.version < pubspec.lock)

echo "Downloading OLM version $OLM_VERSION."

DOWNLOAD_PATH="https://github.com/famedly/olm/releases/download/v$OLM_VERSION/olm.zip"

TMP_DIR="$(mktemp -d)"

pushd "$TMP_DIR"

curl -L -o olm.zip "$DOWNLOAD_PATH"
unzip olm.zip
rm olm.zip
popd

mv "$TMP_DIR/javascript" "$OLM_DEST"

rm -rf "$TMP_DIR"