#!/usr/bin/env bash

set -e

OUTPUT="web/js/olm"

if [ -d "${OUTPUT}" ]; then
  rm -r "${OUTPUT}"
fi

OLM_VERSION=$(yq -r .packages.flutter_olm.version < pubspec.lock)
URL="https://github.com/famedly/olm/releases/download/v$OLM_VERSION/olm.zip"

echo "OLM for web version $OLM_VERSION."
echo "Downloading ${URL} ..."

curl -Lso "olm-${OLM_VERSION}.zip" "${URL}"
unzip -qquod web/js "olm-${OLM_VERSION}.zip" "javascript/*"
mv web/js/javascript "${OUTPUT}"
rm "olm-${OLM_VERSION}.zip"

echo "Stored in : ${OUTPUT}"
