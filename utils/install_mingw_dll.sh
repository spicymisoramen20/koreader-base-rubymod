#!/usr/bin/env bash
# Copy a MinGW/CMake-installed DLL into OUTPUT_DIR/libs.
# Candidates are tried in order (versioned bin/lib, then unversioned).
set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "usage: $0 DEST_DIR CANDIDATE [CANDIDATE...]" >&2
    exit 2
fi

dest_dir="$1"
shift

mkdir -p "${dest_dir}"
for candidate in "$@"; do
    if [[ -f "${candidate}" ]]; then
        cp -f "${candidate}" "${dest_dir}/$(basename "${candidate}")"
        exit 0
    fi
done

echo "missing shared library DLL; tried:" >&2
printf '  %s\n' "$@" >&2
exit 1
