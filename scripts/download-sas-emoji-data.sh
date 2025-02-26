#!/usr/bin/env bash

set -e

OUTPUT="assets/matrix/sas-emoji.json"

MATRIX_ROOT="$(jq -cr '.["packages"][] | select(.name == "matrix").rootUri' < ".dart_tool/package_config.json" | awk -F 'file://' '{ print $2 }')"
SPEC_VERSION="$(grep 'static const Set<String> supportedVersions' "${MATRIX_ROOT}/lib/src/client.dart" | awk -F '=' '{ print $2 }' | awk -F ';' '{ print $1}' | sed "s/'/\"/g" | sed 's/{/[/g' | sed 's/}/]/g' | jq -cr '. | last')"
URL="https://github.com/matrix-org/matrix-spec/raw/refs/tags/${SPEC_VERSION}/data-definitions/sas-emoji.json"

echo "SAS emoji data for [matrix] spec version ${SPEC_VERSION}."
echo "Downloading ${URL} ..."

curl -Lso "${OUTPUT}" "${URL}"
echo "Stored in : ${OUTPUT}"
