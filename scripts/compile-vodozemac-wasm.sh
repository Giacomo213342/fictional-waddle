#!/usr/bin/env bash

set -e

PWD="$(pwd)"
OUTPUT="${PWD}/web/pkg"

if [ -d "${OUTPUT}" ]; then
  rm -r "${OUTPUT}"
fi

VODOZEMAC_FLUTTER_ROOT="$(jq -cr '.["packages"][] | select(.name == "flutter_vodozemac").rootUri' < ".dart_tool/package_config.json" | awk -F 'file://' '{ print $2 }')"
VODOZEMAC_ROOT="$(jq -cr '.["packages"][] | select(.name == "vodozemac").rootUri' < ".dart_tool/package_config.json" | awk -F 'file://' '{ print $2 }')"
VODOZEMAC_VERSION=$(yq -r .packages.flutter_vodozemac.version < pubspec.lock)

echo "Vodozemac for web version $VODOZEMAC_VERSION."

pushd "$(mktemp -d)"

# copy our working directories
cp -r "${VODOZEMAC_FLUTTER_ROOT}" flutter
cp -r "${VODOZEMAC_ROOT}" dart

rustup toolchain install nightly && rustup component add rust-src
flutter_rust_bridge_codegen build-web --dart-root dart --rust-root "$(readlink -f flutter/rust)" --release

cp -pr "dart/web/pkg" "${OUTPUT}"
popd
