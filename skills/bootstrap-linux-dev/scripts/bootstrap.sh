#!/usr/bin/env bash
set -euo pipefail

profile=core
assume_yes=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) profile=${2:?missing profile}; shift 2 ;;
    --yes) assume_yes=1; shift ;;
    -h|--help) echo 'usage: bootstrap.sh [--profile core|full|agent] [--yes]'; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done
case "$profile" in core|full|agent) ;; *) echo "invalid profile: $profile" >&2; exit 2;; esac

if command -v sudo >/dev/null 2>&1; then SUDO=sudo; elif [[ $EUID -eq 0 ]]; then SUDO=; else echo 'root or sudo is required' >&2; exit 1; fi
confirm(){ [[ $assume_yes -eq 1 ]] || { read -r -p "$1 [y/N] " a; [[ $a == [yY] ]]; }; }
install_each(){ local p; for p in "$@"; do echo "Installing $p"; $SUDO "$PM" -y install "$p" || echo "WARN: unavailable or failed: $p" >&2; done; }

if command -v dnf >/dev/null 2>&1; then
  PM=dnf
  core=(git curl wget ca-certificates tar xz unzip jq gcc gcc-c++ make cmake gdb pkgconf-pkg-config)
  full=(lldb clang clang-tools-extra valgrind strace ccache mold bear zsh tmux fd-find ripgrep the_silver_searcher fzf eza zoxide ncdu duf git-delta procs)
  agent=(ShellCheck yq)
  update(){ $SUDO dnf -y upgrade --refresh; }
elif command -v apt-get >/dev/null 2>&1; then
  PM=apt-get
  core=(git curl wget ca-certificates tar xz-utils unzip jq build-essential cmake gdb pkg-config)
  full=(lldb clang clangd clang-format clang-tools valgrind strace ccache mold bear zsh tmux fd-find ripgrep silversearcher-ag fzf eza zoxide ncdu duf git-delta)
  agent=(shellcheck)
  update(){ $SUDO apt-get update && $SUDO apt-get -y upgrade; }
else
  echo 'Unsupported package manager. Read references/package-map.md and install manually.' >&2
  exit 1
fi

packages=("${core[@]}")
[[ $profile == full || $profile == agent ]] && packages+=("${full[@]}")
[[ $profile == agent ]] && packages+=("${agent[@]}")

confirm "Update system packages and install the $profile prerequisites?" || exit 0
update
install_each "${packages[@]}"

cat <<NEXT

$profile system prerequisites installed. Continue with SKILL.md for release-sensitive tools.
- full/agent: Rust, Go, CLI Emacs, Oh My Zsh, CodeLLDB and language utilities
- agent: GitHub CLI, ast-grep, just, direnv, uv/Ruff/pre-commit, shfmt/actionlint,
  age/SOPS, Trivy/Syft/Grype, xh/glow/lazygit
Run scripts/verify.sh --profile $profile after completing the profile.
NEXT
