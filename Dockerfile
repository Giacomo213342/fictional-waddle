FROM registry.gitlab.com/polycule_client/flutter-dockerimages:3.29.2-web AS builder

ARG POLYCULE_IS_STABLE=false
ARG POLYCULE_VERSION=debug
ARG BUILD_NUMBER=null
ARG BASE_HREF="/"

COPY lib /app/lib
COPY web /app/web
COPY assets /app/assets
COPY scripts /app/scripts
COPY l10n.yaml /app
COPY LICENSE /app
COPY pubspec.yaml /app
COPY pubspec.lock /app

WORKDIR /app

RUN ./scripts/download-olm.sh
RUN flutter pub get --enforce-lockfile
RUN flutter gen-l10n
RUN dart compile js web/web_worker.dart -m -o web/web_worker.dart.js
RUN flutter build web --no-pub --native-null-assertions --no-web-resources-cdn --base-href "$BASE_HREF" --source-maps \
    $($POLYCULE_IS_STABLE || echo "--build-number $BUILD_NUMBER") \
    --dart-define=POLYCULE_IS_STABLE=$POLYCULE_IS_STABLE \
    --dart-define=POLYCULE_VERSION=$POLYCULE_VERSION \
    --dart-define=no_default_http_client=true \
    --dart-define=cronetHttpNoPlay=true \
    --dart-define=no_default_http_client=false

FROM nginx:1.27.4-alpine-slim

LABEL org.opencontainers.image.source=https://gitlab.com/polycule_client/polycule.git

COPY --from=builder /app/build/web /usr/share/nginx/html/
