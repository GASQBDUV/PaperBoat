#!/bin/bash
# bananaOS ports entry. PAPERBOAT_SCREENS=dual (default) | swap | single
export PAPERBOAT_SCREENS=${PAPERBOAT_SCREENS:-dual}
export PAPERBOAT_DIR="$(dirname "$(readlink -f "$0")")/paperboat"
exec /bin/bash "$PAPERBOAT_DIR/run-paperboat.sh"
