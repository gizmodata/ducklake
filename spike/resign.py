"""Sign a DuckDB extension's existing payload/metadata with an RSA-2048 test key."""
import argparse
import gzip
import hashlib
from pathlib import Path
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--input', required=True, type=Path)
parser.add_argument('--output', required=True, type=Path)
parser.add_argument('--private-key', required=True, type=Path)
args = parser.parse_args()
data = args.input.read_bytes()
if len(data) < 512:
    parser.error('extension is too short to contain a DuckDB footer')
body = data[:-256]
chunk_hashes = b''.join(hashlib.sha256(body[start:start + 1024 * 1024]).digest()
                        for start in range(0, len(body), 1024 * 1024))
digest = hashlib.sha256(chunk_hashes).digest()
with tempfile.TemporaryDirectory(prefix='ducklake-sign-') as directory:
    hash_path = Path(directory) / 'digest'
    signature_path = Path(directory) / 'signature'
    hash_path.write_bytes(digest)
    subprocess.run(args=['openssl', 'pkeyutl', '-sign', '-inkey', str(args.private_key),
                         '-pkeyopt', 'digest:sha256', '-in', str(hash_path), '-out', str(signature_path)], check=True)
    signature = signature_path.read_bytes()
if len(signature) != 256:
    parser.error('expected a 256-byte RSA-2048 signature')
output = body + signature
args.output.parent.mkdir(parents=True, exist_ok=True)
args.output.write_bytes(output)
args.output.with_suffix(args.output.suffix + '.gz').write_bytes(gzip.compress(data=output, mtime=0))
print(args.output.name, hashlib.sha256(output).hexdigest())
