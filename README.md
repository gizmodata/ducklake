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

## Install from this artifact repository

Only **linux_arm64** is included. Pin the artifact commit SHA in the URL, rather than a moving branch.
Use the base64 body from `public_key.pem` as the SQL public key:

```sql
SET autoinstall_known_extensions = false;
SET allow_extension_repositories = 'allowed';
CREATE EXTENSION REPOSITORY IF NOT EXISTS agc
  WITH PREFIX 'https://raw.githubusercontent.com/gizmodata/ducklake/<artifact-commit-sha>'
  USING PUBLIC KEY '<base64 body of public_key.pem>';
INSTALL ducklake FROM agc;
LOAD ducklake FROM agc;
SELECT CASE WHEN count(*) = 0 THEN error('signed spike not loaded') END
FROM duckdb_functions() WHERE function_name = 'ducklake_spike_build';
SELECT ducklake_spike_build();
SET allow_extension_repositories = 'forbidden';
```

Run before the first DuckLake load in a fresh process. This cannot replace already loaded native code.
Hardcharger 2.0.0 loads its built-in before init SQL: `LOAD ... FROM agc` keeps the built-in active,
and an aliased load conflicts with its registrations. The guard above deliberately fails Hardcharger startup.
A real branching-build guard should still check `ducklake_branches`; this stand-in does not supply it.

See `manifest.json` for the exact source commits, artifact hashes and signing-key fingerprint.
Licenses are included in `LICENSE` and `licenses/`. No private signing key is published.
