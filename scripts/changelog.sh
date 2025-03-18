#!/usr/bin/env bash

RELEASE="$1"
BUILD="$(echo "$RELEASE" | sed 's/\.//g' | sed 's/0//g')"

if [ -z "$RELEASE" ]; then
  echo -e "changelog.sh VERSION\n\n\tVERSION = MAJOR.MINOR.PATCH, e.g. 1.0.2"
  exit 1
fi

if grep -q "v${RELEASE}" CHANGELOG.md; then
  echo "Found v${RELEASE} in CHANGELOG.md. Please remove before running the scipt again."
  exit 2
fi

CHANGELOG="$(git log "$(git describe --tags --always --abbrev=0)..HEAD" --pretty=format:'- %s %C(bold blue)(%an)%Creset' --no-merges --no-decorate | sort -uk2)"

echo -e "\n----------\n\nChangelog for v${RELEASE} (${BUILD}) :\n\n${CHANGELOG}\n\n----------\n"

# main changelog
echo -e "## v${RELEASE}\n\n${CHANGELOG}\n\n$(cat CHANGELOG.md)" > "CHANGELOG.md"
git add "CHANGELOG.md"

# fastlane changelogs
for SUFFIX in 1 2 4;
do
  FILE="fastlane/metadata/android/en-US/changelogs/${BUILD}${SUFFIX}.txt"
  echo -e "${CHANGELOG}" > "${FILE}"
  git add "${FILE}"
done

echo -e "Updated CHANGELOG.md, fastlane/metadata/android/en-US/changelogs/${BUILD}{1,2,4}.txt\n"

# shellcheck disable=SC1078
COMMAND="git tag -f v${RELEASE} -m \"\$(git log \"\$(git describe --tags --always --abbrev=0)..HEAD^1\" --pretty=format:'- %s %C(bold blue)(%an)%Creset' --no-merges --no-decorate | sort -uk2)\""

echo -e "Run the following command to tag a release :\n\n\t${COMMAND}\n"
