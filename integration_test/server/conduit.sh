#!/usr/bin/env bash

set -em

docker run --rm --name homeserver -p 80:80 --pull always \
  --network host \
  -e CONDUIT_SERVER_NAME="homeserver" \
  -e CONDUIT_PORT="80" \
  -e CONDUIT_ADDRESS="::" \
  -e CONDUIT_DATABASE_BACKEND="rocksdb" \
  -e CONDUIT_DATABASE_PATH="/rocksdb" \
  -e CONDUIT_ALLOW_REGISTRATION="true" \
  -e CONDUIT_REGISTRATION_SECRET="${REGISTRATION_TOKEN:-"SomeSecret"}" \
  -e CONDUIT_LOG="info,rocket=off,_=off,sled=off" \
  -e CONDUIT_WELL_KNOWN_CLIENT="http://${HOMESERVER:-"homeserver"}" \
  -e CONDUIT_CONFIG="" \
  "matrixconduit/matrix-conduit:${CONDUIT_VERSION:-latest}"
