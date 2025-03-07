#!/usr/bin/env bash

set -e

if [ -n "${FLUTTER_VERSION}" ]; then
  FLUTTER_VERSION="$(cat flutter_version)"
fi

export FLUTTER_VERSION

export FLUTTER_HOME="$HOME/build/flutter-${FLUTTER_VERSION}"
export FLUTTER_GIT_URL="unknown source"
export PATH="${FLUTTER_HOME}/bin:${PATH}"
export LANG=en_US.UTF-8

# create a clean build environment for our Python toolchain
rm -rf .buildenv
python3 -m virtualenv .buildenv

if [ ! -f "${FLUTTER_HOME}/bin/flutter" ]; then
  git clone -b "${FLUTTER_VERSION}" --depth 1 https://github.com/flutter/flutter.git "${FLUTTER_HOME}"

	git -C "${FLUTTER_HOME}" switch -C stable
	git -C "${FLUTTER_HOME}" branch origin/master

	flutter --suppress-analytics channel stable --no-cache-artifacts
  flutter --suppress-analytics precache --universal --ios --macos

  flutter doctor -v
fi

flutter --disable-analytics
dart --disable-analytics

source .buildenv/bin/activate
pip install codemagic-cli-tools

gem install --update xcodeproj
pod repo update
