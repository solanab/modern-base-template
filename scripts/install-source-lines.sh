#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
install_dir="${SOURCE_LINES_INSTALL_DIR:-$root_dir/runtime/tools/bin}"
requested_version="${1:?usage: install-source-lines.sh VERSION}"
version="${requested_version#v}"
binary="$install_dir/source-lines"
receipt="$install_dir/.source-lines-install-version"

fail() {
  printf 'source-lines consumer install: %s\n' "$*" >&2
  exit 1
}

case "$version" in
  0.2.0) installer_checksum="8794c3fd0c1c3d23e61b198e848259fd72d406f314b05c947a8342c15e411fac" ;;
  0.3.0) installer_checksum="c114f1b704fd4522dc45b3e72afd8b8d946d86562f644f756888f83c4970dd8c" ;;
  *) fail "no installer checksum pinned for source-lines $version" ;;
esac

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    command -v shasum >/dev/null 2>&1 || fail 'required command not found: sha256sum or shasum'
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

if [[ -x "$binary" ]] \
  && [[ -f "$receipt" ]] \
  && [[ "$(<"$receipt")" == "$version" ]] \
  && [[ "$("$binary" --version 2>/dev/null || true)" == "source-lines $version" ]]; then
  printf 'source-lines %s already installed\n' "$version"
  exit 0
fi

command -v curl >/dev/null 2>&1 || fail "required command not found: curl"
command -v mktemp >/dev/null 2>&1 || fail "required command not found: mktemp"

temp_root="${TMPDIR:-/tmp}"
temp_dir="$(mktemp -d "${temp_root%/}/source-lines-consumer.XXXXXX")"
trap 'rm -rf -- "$temp_dir"' EXIT
installer="$temp_dir/install.sh"
installer_url="https://github.com/solanab/source-lines-dist/releases/download/v${version}/install.sh"

curl --fail --location --silent --show-error --output "$installer" "$installer_url" \
  || fail "could not fetch public installer for v${version}"

actual_checksum="$(sha256_file "$installer")"
[[ "$actual_checksum" == "$installer_checksum" ]] \
  || fail "installer checksum mismatch for v${version}: expected $installer_checksum, got $actual_checksum"

SOURCE_LINES_INSTALL_DIR="$install_dir" sh "$installer" "$version"
printf '%s\n' "$version" >"$receipt"
