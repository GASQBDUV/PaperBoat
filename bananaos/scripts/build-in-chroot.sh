#!/bin/sh
# Körs INNE i trixie-chrooten (chroot /opt/trixie sh /root/build-paperboat.sh). Korsbygger PaperBoat (aarch64) för BananaOS.
# Källa: /work/pb (PaperBoat + submoduler, commit 7f038b8). Resultat: /out-pb/Paperboat
set -e
SRC=${SRC:-/work/pb}; B=${B:-/work/pb-build}; OUT=${OUT:-/out-pb}
mkdir -p "$B" "$OUT"
cat > /work/tc-pb.cmake <<TC
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_C_COMPILER_TARGET aarch64-linux-gnu)
set(CMAKE_CXX_COMPILER_TARGET aarch64-linux-gnu)
set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld -lfmt -lspdlog")
set(CMAKE_SHARED_LINKER_FLAGS_INIT -fuse-ld=lld)
set(CMAKE_FIND_ROOT_PATH /usr/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
TC
export PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/share/pkgconfig
cd "$B"
[ -f build.ninja ] && grep -q "CMAKE_CXX_COMPILER:.*clang" CMakeCache.txt || { rm -rf "$B"/CMakeCache.txt "$B"/CMakeFiles; }
cat > /work/pre.h <<PRE
#include <spdlog/spdlog.h>
#include <spdlog/fmt/fmt.h>
#include <fmt/format.h>
#include <fmt/ostream.h>
#include <fmt/ranges.h>
#include <fmt/chrono.h>
PRE
cmake -G Ninja -S "$SRC" -B "$B" -DCMAKE_TOOLCHAIN_FILE=/work/tc-pb.cmake \
    -DUSE_OPENGLES=1 -DCMAKE_BUILD_TYPE=Release -DCPU_OPTION=-mcpu=cortex-a53 "-DCMAKE_CXX_FLAGS=-include /work/pre.h" ${CMAKE_EXTRA}
ninja ${TARGET:-Paperboat}
cp -v "$B/Paperboat" "$OUT/" 2>/dev/null || find "$B" -maxdepth 2 -name Paperboat -type f
