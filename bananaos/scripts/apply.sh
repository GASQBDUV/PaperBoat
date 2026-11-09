#!/bin/sh
# Applies the bananaOS patch to the libultraship submodule (the PaperBoat src/ changes are already in this branch).
set -e
cd "$(dirname "$0")/../.."
git submodule update --init --recursive
cd external/libultraship
git apply --check ../../bananaos/patches/libultraship-bananaos.patch
git apply ../../bananaos/patches/libultraship-bananaos.patch
echo "libultraship patched"
