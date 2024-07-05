#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# duplicate the global gitconfig to a writable location if not root
if (( UID ));then
    USER_WRITABLE="/tmp/$(basename "${GIT_CONFIG_GLOBAL}-uid-${UID}")"
    cp "$GIT_CONFIG_GLOBAL" "${USER_WRITABLE}"
    GIT_CONFIG_GLOBAL="${USER_WRITABLE}"
fi

exec "$@"
