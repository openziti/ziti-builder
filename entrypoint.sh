#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [ "${RUNNER_ENVIRONMENT}" == "github-hosted" ]; then
    echo "running in github-hosted runner"
    if [ -d /__e/node20 -a "${UID}" -eq 0 ]; then
        echo "replacing /__e/node20 with unofficial build that works with glibc 2.27 (ubuntu 18)"
        mv /__e/node20 /__e/node20.orig
        cp -pr /usr/local/node20 /__e/
    fi
fi

# duplicate the global gitconfig to a writable location if not root
if (( UID ));then
    USER_WRITABLE="${GIT_CONFIG_GLOBAL}-uid-$UID"
    cp "$GIT_CONFIG_GLOBAL" "$USER_WRITABLE"
    GIT_CONFIG_GLOBAL="$USER_WRITABLE"
fi

exec "$@"
