#!/bin/bash
set -euo pipefail
cmake -S /duckdb -B /work/ga-build -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_UNITTESTS=OFF -DBUILD_SHELL=OFF -DEXTENSION_STATIC_BUILD=ON -DDUCKDB_EXTENSION_CONFIGS=/work/ga-extension.cmake -DDUCKDB_EXPLICIT_VERSION=v2.0.0 -DGIT_COMMIT_HASH=d54cbbe3df1 -DCMAKE_PREFIX_PATH=/work/roaring-install -DDISABLE_UNITY=OFF -DCXX_EXTRA=-O1
cmake --build /work/ga-build --target ducklake_loadable_extension -j 3
