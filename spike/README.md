# Signed DuckLake 1.1 spike

Experimental test build based on upstream DuckLake commit `417a9117f590e8141742ac0579d02f6a90162e37`,
the revision pinned by DuckDB v2.0.0. Upstream has no 1.1 Git release tag; its catalog-format default
at this revision is **1.1** (`src/include/common/ducklake_version.hpp`).

This is not a branching implementation. The only added SQL function is the test marker
`ducklake_spike_build()`, returning `gd-spike-1.1`. A real branching-build guard must still check
for the actual branching function.

Build the loadable extension for the exact DuckDB version and platform. DuckLake uses the C++
extension ABI, so a final 2.0.0 binary cannot be used in a 2.0 alpha process.

- GA branch: upstream 417a9117 plus the marker, for DuckDB v2.0.0.
- Edge compatibility branch: the same source plus the marker, adapting the memory-size helper
  and dynamic-filter mutex guards to the older DuckDB v2.0.0-alpha46057 headers. The older
  `ParseMemoryLimit` returns a maximum value for unlimited, matching GA's `ParseMemoryLimitOrMaximum`.
  The old filter lock is a plain mutex, so it uses an exclusive lock guard. The Edge build also
  calls the older postgres extension's `pg_clear_cache()` name instead of `postgres_clear_cache()`.

`resign.py` replaces only the 256-byte extension signature. It hashes 1 MiB chunks of the payload
including metadata, hashes the concatenated chunk hashes, and signs that digest using RSA-2048
PKCS#1 v1.5/SHA-256. Keep the private key outside this repository. Test artifacts and the public key
are published on the `signed-ducklake-spike` branch after container validation.

This test key and these artifacts are for the spike, not a production trust configuration.
