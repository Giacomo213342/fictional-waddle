#!/usr/bin/env bash

set -e

OUTPUT="assets/matrix/sas-emoji.json"
SPEC_KEY="static const Set<String> supportedVersions ="

MATRIX_ROOT="$(jq -cr '.["packages"][] | select(.name == "matrix").rootUri' < ".dart_tool/package_config.json" | awk -F 'file://' '{ print $2 }')"
SPEC_VERSION="$(grep -Pzo '(?s)(\s*)\N*'"${SPEC_KEY}"' {.*?\1}' "${MATRIX_ROOT}/lib/src/client.dart" | tail -n2 | head -n1 | sed -r "s/\\s*'v?,?//g")"
URL="https://github.com/matrix-org/matrix-spec/archive/refs/tags/v${SPEC_VERSION}.tar.gz"

echo "SAS emoji data for [matrix] spec version ${SPEC_VERSION}."
echo "Downloading ${URL} ..."

curl -Ls "${URL}" | tar -xzOf - "matrix-spec-${SPEC_VERSION}/data-definitions/sas-emoji.json" > "$OUTPUT"
echo "Stored in : ${OUTPUT}"
