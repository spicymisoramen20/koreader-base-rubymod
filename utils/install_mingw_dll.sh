#!/usr/bin/env bash
# Copy a MinGW/CMake-installed DLL into OUTPUT_DIR/libs.
# Candidates are tried in order (versioned bin/lib, then unversioned).
# If none match exactly, fall back to globbing NAME-*.dll from the same
# directories (leptonica installs libleptonica-1.87.0.dll while set_libname
# asks for libleptonica-6.dll).
set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "usage: $0 DEST_DIR CANDIDATE [CANDIDATE...]" >&2
    exit 2
fi

dest_dir="$1"
shift

mkdir -p "${dest_dir}"

copy_if_present() {
    local candidate="$1"
    if [[ -f "${candidate}" ]]; then
        cp -f "${candidate}" "${dest_dir}/$(basename "${candidate}")"
        exit 0
    fi
}

for candidate in "$@"; do
    copy_if_present "${candidate}"
done

# Fallback: strip the last -<soversion> from the first candidate and glob.
first="$1"
base="$(basename "${first}" .dll)"
stem="${base%-*}"
dirs=""
for candidate in "$@"; do
    d="$(dirname "${candidate}")"
    case " ${dirs} " in
        *" ${d} "*) ;;
        *) dirs="${dirs} ${d}" ;;
    esac
done

# shellcheck disable=SC2086
for d in ${dirs}; do
    # Prefer a versioned DLL over a plain NAME.dll if both exist.
    # Lexicographically last tends to be the full VERSION for leptonica.
    pick=""
    for m in $(ls -1 "${d}/${stem}"-*.dll 2>/dev/null | sort); do
        pick="${m}"
    done
    if [[ -n "${pick}" ]]; then
        copy_if_present "${pick}"
    fi
    copy_if_present "${d}/${stem}.dll"
done

echo "missing shared library DLL; tried:" >&2
printf '  %s\n' "$@" >&2
printf '  (glob fallback stem=%s)\n' "${stem}" >&2
exit 1
