#!/bin/bash
set -euo pipefail
cmake -S /work/roaring-src -B /work/roaring-build -G Ninja -DCMAKE_BUILD_TYPE=Release -DENABLE_ROARING_TESTS=OFF -DROARING_BUILD_STATIC=ON -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX=/work/roaring-install
cmake --build /work/roaring-build -j 2
cmake --install /work/roaring-build
cmake -S /duckdb -B /work/edge-build -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_UNITTESTS=OFF -DBUILD_SHELL=OFF -DEXTENSION_STATIC_BUILD=ON -DDUCKDB_EXTENSION_CONFIGS=/work/edge-extension.cmake -DDUCKDB_EXPLICIT_VERSION=v2.0.0-alpha46057 -DGIT_COMMIT_HASH=b15358c371d -DCMAKE_PREFIX_PATH=/work/roaring-install -DDISABLE_UNITY=OFF -DCXX_EXTRA=-O1
cmake --build /work/edge-build --target ducklake_loadable_extension -j 2
