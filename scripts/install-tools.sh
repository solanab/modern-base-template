#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bin_dir="${MODERN_BASE_TEMPLATE_TOOL_BIN_DIR:-$root_dir/runtime/tools/bin}"
shfmt_version="3.13.1"
shellcheck_version="0.11.0"
tombi_version="1.4.1"
actionlint_version="1.7.12"
dprint_version="0.56.1"
rumdl_version="0.2.60"
yamlfmt_version="0.21.0"
temp_dir=""

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'required command not found: %s\n' "$1" >&2
    exit 1
  }
}

platform_name() {
  case "$(uname -s)" in
    Linux) printf 'linux' ;;
    Darwin) printf 'darwin' ;;
    *)
      printf 'unsupported operating system: %s\n' "$(uname -s)" >&2
      exit 1
      ;;
  esac
}

architecture_name() {
  case "$(uname -m)" in
    x86_64 | amd64) printf 'amd64' ;;
    arm64 | aarch64) printf 'arm64' ;;
    *)
      printf 'unsupported architecture: %s\n' "$(uname -m)" >&2
      exit 1
      ;;
  esac
}

shfmt_checksum() {
  case "$1-$2" in
    linux-amd64) printf 'fb096c5d1ac6beabbdbaa2874d025badb03ee07929f0c9ff67563ce8c75398b1' ;;
    linux-arm64) printf '32d92acaa5cd8abb29fc49dac123dc412442d5713967819d8af2c29f1b3857c7' ;;
    darwin-amd64) printf '6feedafc72915794163114f512348e2437d080d0047ef8b8fa2ec63b575f12af' ;;
    darwin-arm64) printf '9680526be4a66ea1ffe988ed08af58e1400fe1e4f4aef5bd88b20bb9b3da33f8' ;;
  esac
}

shellcheck_checksum() {
  case "$1-$2" in
    linux-amd64) printf 'b7af85e41cc99489dcc21d66c6d5f3685138f06d34651e6d34b42ec6d54fe6f6' ;;
    linux-arm64) printf '68a8133197a50beb8803f8d42f9908d1af1c5540d4bb05fdfca8c1fa47decefc' ;;
    darwin-amd64) printf 'c2c15e08df0e8fbc374c335b230a7ee958c313fa5714817a59aa59f1aa594f51' ;;
    darwin-arm64) printf '339b930feb1ea764467013cc1f72d09cd6b869ebf1013296ba9055ab2ffbd26f' ;;
  esac
}

tombi_checksum() {
  case "$1-$2" in
    linux-amd64) printf '9aa69eb3e75a4a22a961b8a1c8cc44e4f81328ce25ad5b10d151be1a09faa88d' ;;
    linux-arm64) printf '21f51d092597053266e0ed051082743b5956b6de2f0db1cecce78e0eb29165e5' ;;
    darwin-amd64) printf '4a14a0bf18ec0bbbeab3003f6c0dea3ffabb2cb38649ebfd6cafabc4d7eeffe0' ;;
    darwin-arm64) printf '0054ea75a98db2ccdef3b304bf97aeb2b1fed201df13b30b68a19672a275199c' ;;
  esac
}

actionlint_checksum() {
  case "$1-$2" in
    linux-amd64) printf '8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8' ;;
    linux-arm64) printf '325e971b6ba9bfa504672e29be93c24981eeb1c07576d730e9f7c8805afff0c6' ;;
    darwin-amd64) printf '5b44c3bc2255115c9b69e30efc0fecdf498fdb63c5d58e17084fd5f16324c644' ;;
    darwin-arm64) printf 'aba9ced2dee8d27fecca3dc7feb1a7f9a52caefa1eb46f3271ea66b6e0e6953f' ;;
  esac
}

dprint_checksum() {
  case "$1-$2" in
    linux-amd64) printf '51729ee501593c84e2a2e8233f55959edf2bbd95cbb3998e9f8a81ecad942dba' ;;
    linux-arm64) printf 'e9dc29baca00edf30d66b1b7a8de490c3a1bda4091bbc7b69f01f4a88db06c01' ;;
    darwin-amd64) printf 'f944e33a1bf8f6125eaa5ea77ee8a01db96093a6fb80df127b390f2a106774f7' ;;
    darwin-arm64) printf 'c9af77af134987fada60344e8b9f23b2238081f7eea94a7bcd53ec49369354f6' ;;
  esac
}

rumdl_checksum() {
  case "$1-$2" in
    linux-amd64) printf '84fc96856d21203b6482b7284aff5b539b7329a5cc078d7a94c55ae40d88752f' ;;
    linux-arm64) printf '02a34cc98282f0f0799dcf9d3b5eac0cc84f98cda85df1c6486178dbc5451c54' ;;
    darwin-amd64) printf 'bbd0618d6b2e3b4de94d85b228614b45462754a27e62c5560fb3c208e4aa719d' ;;
    darwin-arm64) printf 'f195e442ffa87fca71b3362333fd0c7b4818913ee84421917fa1a9638693b01f' ;;
  esac
}

yamlfmt_checksum() {
  case "$1-$2" in
    linux-amd64) printf '1f300d9257b232bb3b541d7fb1b0e6b3c121bcbab381c86cd38cb8722be8a566' ;;
    linux-arm64) printf '5b2689c963b177271330c5ce8ca7396751107e5a826be46f03d2cb9b6f0c7784' ;;
    darwin-amd64) printf '060e943bcb8583c456810eb1ff4721b4f46c4a0c1a4432449d5dc3bbfe29a22b' ;;
    darwin-arm64) printf '4b417ecb94339d57e4c122ecc948c1a00fe328b5853266de9806e652a92858fa' ;;
  esac
}

verify_checksum() {
  local archive="$1" expected="$2" actual
  if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "$archive" | awk '{print $1}')"
  else
    require_command shasum
    actual="$(shasum -a 256 "$archive" | awk '{print $1}')"
  fi
  if [[ "$actual" != "$expected" ]]; then
    printf 'checksum mismatch for %s\nexpected: %s\nactual:   %s\n' "$archive" "$expected" "$actual" >&2
    exit 1
  fi
}

download() {
  local url="$1" destination="$2" checksum="$3"
  curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location --retry 3 \
    --output "$destination" "$url"
  verify_checksum "$destination" "$checksum"
}

install_shfmt() {
  local os_name="$1" arch_name="$2" temp_path="$3"
  local binary="$bin_dir/shfmt" archive_name archive_url archive_path
  if [[ -x "$binary" ]] && "$binary" --version 2>/dev/null | grep -q "^v$shfmt_version\$"; then
    printf 'shfmt %s already installed\n' "$shfmt_version"
    return
  fi

  archive_name="shfmt_v${shfmt_version}_${os_name}_${arch_name}"
  archive_url="https://github.com/mvdan/sh/releases/download/v${shfmt_version}/${archive_name}"
  archive_path="$temp_path/$archive_name"
  download "$archive_url" "$archive_path" "$(shfmt_checksum "$os_name" "$arch_name")"
  install -m 0755 "$archive_path" "$binary"
  printf 'installed shfmt %s\n' "$shfmt_version"
}

install_shellcheck() {
  local os_name="$1" arch_name="$2" temp_path="$3" shell_arch
  local binary="$bin_dir/shellcheck" archive_name archive_url archive_path extracted_dir
  if [[ -x "$binary" ]] && "$binary" --version 2>/dev/null | grep -q "version: $shellcheck_version"; then
    printf 'ShellCheck %s already installed\n' "$shellcheck_version"
    return
  fi

  case "$arch_name" in
    amd64) shell_arch="x86_64" ;;
    arm64) shell_arch="aarch64" ;;
  esac
  archive_name="shellcheck-v${shellcheck_version}.${os_name}.${shell_arch}.tar.gz"
  archive_url="https://github.com/koalaman/shellcheck/releases/download/v${shellcheck_version}/${archive_name}"
  archive_path="$temp_path/$archive_name"
  extracted_dir="$temp_path/shellcheck-v${shellcheck_version}"
  download "$archive_url" "$archive_path" "$(shellcheck_checksum "$os_name" "$arch_name")"
  tar -xzf "$archive_path" -C "$temp_path"
  install -m 0755 "$extracted_dir/shellcheck" "$binary"
  printf 'installed ShellCheck %s\n' "$shellcheck_version"
}

install_tombi() {
  local os_name="$1" arch_name="$2" temp_path="$3" target
  local binary="$bin_dir/tombi" archive_name archive_url archive_path extracted_dir
  if [[ -x "$binary" ]] && "$binary" --version 2>/dev/null | grep -q "^tombi $tombi_version "; then
    printf 'Tombi %s already installed\n' "$tombi_version"
    return
  fi

  case "$os_name-$arch_name" in
    linux-amd64) target="x86_64-unknown-linux-musl" ;;
    linux-arm64) target="aarch64-unknown-linux-musl" ;;
    darwin-amd64) target="x86_64-apple-darwin" ;;
    darwin-arm64) target="aarch64-apple-darwin" ;;
  esac
  archive_name="tombi-cli-${tombi_version}-${target}.tar.gz"
  archive_url="https://github.com/tombi-toml/tombi/releases/download/v${tombi_version}/${archive_name}"
  archive_path="$temp_path/$archive_name"
  extracted_dir="$temp_path/${archive_name%.tar.gz}"
  download "$archive_url" "$archive_path" "$(tombi_checksum "$os_name" "$arch_name")"
  tar -xzf "$archive_path" -C "$temp_path"
  install -m 0755 "$extracted_dir/tombi" "$binary"
  printf 'installed Tombi %s\n' "$tombi_version"
}

install_actionlint() {
  local os_name="$1" arch_name="$2" temp_path="$3"
  local binary="$bin_dir/actionlint" archive_name archive_url archive_path
  if [[ -x "$binary" ]] && "$binary" --version 2>/dev/null | head -1 | grep -q "^$actionlint_version\$"; then
    printf 'actionlint %s already installed\n' "$actionlint_version"
    return
  fi

  archive_name="actionlint_${actionlint_version}_${os_name}_${arch_name}.tar.gz"
  archive_url="https://github.com/rhysd/actionlint/releases/download/v${actionlint_version}/${archive_name}"
  archive_path="$temp_path/$archive_name"
  download "$archive_url" "$archive_path" "$(actionlint_checksum "$os_name" "$arch_name")"
  tar -xzf "$archive_path" -C "$temp_path" actionlint
  install -m 0755 "$temp_path/actionlint" "$binary"
  printf 'installed actionlint %s\n' "$actionlint_version"
}

install_dprint() {
  local os_name="$1" arch_name="$2" temp_path="$3" target
  local binary="$bin_dir/dprint" archive_name archive_url archive_path
  if [[ -x "$binary" ]] && "$binary" --version 2>/dev/null | grep -q "dprint $dprint_version"; then
    printf 'dprint %s already installed\n' "$dprint_version"
    return
  fi

  case "$os_name-$arch_name" in
    linux-amd64) target="x86_64-unknown-linux-gnu" ;;
    linux-arm64) target="aarch64-unknown-linux-gnu" ;;
    darwin-amd64) target="x86_64-apple-darwin" ;;
    darwin-arm64) target="aarch64-apple-darwin" ;;
  esac
  archive_name="dprint-${target}.zip"
  archive_url="https://github.com/dprint/dprint/releases/download/${dprint_version}/${archive_name}"
  archive_path="$temp_path/$archive_name"
  download "$archive_url" "$archive_path" "$(dprint_checksum "$os_name" "$arch_name")"
  unzip -q -o "$archive_path" dprint -d "$temp_path"
  install -m 0755 "$temp_path/dprint" "$binary"
  printf 'installed dprint %s\n' "$dprint_version"
}

install_rumdl() {
  local os_name="$1" arch_name="$2" temp_path="$3" target
  local binary="$bin_dir/rumdl" archive_name archive_url archive_path
  if [[ -x "$binary" ]] && "$binary" --version 2>/dev/null | grep -q "rumdl $rumdl_version"; then
    printf 'rumdl %s already installed\n' "$rumdl_version"
    return
  fi

  case "$os_name-$arch_name" in
    linux-amd64) target="x86_64-unknown-linux-gnu" ;;
    linux-arm64) target="aarch64-unknown-linux-gnu" ;;
    darwin-amd64) target="x86_64-apple-darwin" ;;
    darwin-arm64) target="aarch64-apple-darwin" ;;
  esac
  archive_name="rumdl-v${rumdl_version}-${target}.tar.gz"
  archive_url="https://github.com/rvben/rumdl/releases/download/v${rumdl_version}/${archive_name}"
  archive_path="$temp_path/$archive_name"
  download "$archive_url" "$archive_path" "$(rumdl_checksum "$os_name" "$arch_name")"
  tar -xzf "$archive_path" -C "$temp_path" rumdl
  install -m 0755 "$temp_path/rumdl" "$binary"
  printf 'installed rumdl %s\n' "$rumdl_version"
}

install_yamlfmt() {
  local os_name="$1" arch_name="$2" temp_path="$3" release_os release_arch
  local binary="$bin_dir/yamlfmt" archive_name archive_url archive_path
  if [[ -x "$binary" ]] && [[ "$(cat "${bin_dir}/.yamlfmt-install-version" 2>/dev/null || true)" == "$yamlfmt_version" ]]; then
    printf 'yamlfmt %s already installed\n' "$yamlfmt_version"
    return
  fi

  case "$os_name" in
    linux) release_os="Linux" ;;
    darwin) release_os="Darwin" ;;
  esac
  case "$arch_name" in
    amd64) release_arch="x86_64" ;;
    arm64) release_arch="arm64" ;;
  esac
  archive_name="yamlfmt_${yamlfmt_version}_${release_os}_${release_arch}.tar.gz"
  archive_url="https://github.com/google/yamlfmt/releases/download/v${yamlfmt_version}/${archive_name}"
  archive_path="$temp_path/$archive_name"
  download "$archive_url" "$archive_path" "$(yamlfmt_checksum "$os_name" "$arch_name")"
  tar -xzf "$archive_path" -C "$temp_path" yamlfmt
  install -m 0755 "$temp_path/yamlfmt" "$binary"
  printf '%s\n' "$yamlfmt_version" >"${bin_dir}/.yamlfmt-install-version"
  printf 'installed yamlfmt %s\n' "$yamlfmt_version"
}

main() {
  local os_name arch_name temp_root
  require_command awk
  require_command curl
  require_command grep
  require_command install
  require_command tar
  require_command unzip

  os_name="$(platform_name)"
  arch_name="$(architecture_name)"
  temp_root="${TMPDIR:-/tmp}"
  temp_dir="$(mktemp -d "${temp_root%/}/modern-base-template-tools.XXXXXX")"
  trap 'rm -rf -- "$temp_dir"' EXIT
  mkdir -p "$bin_dir"

  install_shfmt "$os_name" "$arch_name" "$temp_dir"
  install_shellcheck "$os_name" "$arch_name" "$temp_dir"
  install_tombi "$os_name" "$arch_name" "$temp_dir"
  install_actionlint "$os_name" "$arch_name" "$temp_dir"
  install_dprint "$os_name" "$arch_name" "$temp_dir"
  install_rumdl "$os_name" "$arch_name" "$temp_dir"
  install_yamlfmt "$os_name" "$arch_name" "$temp_dir"
}

main "$@"
