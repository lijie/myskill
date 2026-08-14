#!/usr/bin/env bash
set -uo pipefail

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:$PATH"

section() { printf '\n=== %s ===\n' "$1"; }
show_command() {
  local name=$1
  if command -v "$name" >/dev/null 2>&1; then
    printf '%-18s %s\n' "$name" "$(command -v "$name")"
  else
    printf '%-18s MISSING\n' "$name"
  fi
}
show_providers() {
  local name=$1
  printf '%-12s' "$name"
  type -a "$name" 2>/dev/null | sed -E 's/^[^ ]+ is (an alias for )?//' | awk '!seen[$0]++' | paste -sd ' | ' -
}
brew_has_formula() {
  grep -Fxq "$1" <<< "${BREW_FORMULAE:-}"
}
brew_has_cask() {
  grep -Fxq "$1" <<< "${BREW_CASKS:-}"
}

section "macOS"
sw_vers 2>/dev/null || true
uname -m
uname -a

section "Hardware and resources"
sysctl -n machdep.cpu.brand_string 2>/dev/null || true
sysctl -n hw.ncpu 2>/dev/null || true
sysctl -n hw.memsize 2>/dev/null | awk '{printf "memory_bytes=%s\n", $1}' || true
df -h / 2>/dev/null || true

section "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  printf 'developer_dir=%s\n' "$(xcode-select -p)"
  clang --version 2>/dev/null | head -n 1 || true
else
  echo "MISSING: run 'xcode-select --install' interactively"
fi
pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto 2>/dev/null | sed -n '1,4p' || echo "rosetta=not-detected"

section "Identity and shell"
id
printf 'login_shell=%s\n' "${SHELL:-unknown}"
dscl . -read "/Users/$USER" UserShell 2>/dev/null || true
fish --version 2>/dev/null || true

section "Homebrew"
if command -v brew >/dev/null 2>&1; then
  BREW_FORMULAE="$(brew list --formula 2>/dev/null || true)"
  BREW_CASKS="$(brew list --cask 2>/dev/null || true)"
  printf 'brew=%s\n' "$(command -v brew)"
  printf 'prefix=%s\n' "$(brew --prefix)"
  brew --version | head -n 1
  echo "-- leaves --"
  brew leaves 2>/dev/null | sort || true
  echo "-- casks --"
  printf '%s\n' "$BREW_CASKS" | sort
  echo "-- outdated (report only) --"
  brew outdated 2>/dev/null || true
else
  echo "MISSING"
fi

section "Tool inventory"
tools=(
  git gh git-lfs gcc clang clangd lldb make cmake ninja pkg-config bear
  fish tmux emacs rustup rustc cargo rust-analyzer go gopls dlv
  node npm corepack pnpm yarn fd rg fzf bat eza zoxide tree yazi jq yq
  delta lazygit just direnv uv ruff pre-commit shellcheck shfmt actionlint
  ast-grep trivy syft grype age sops xh glow hyperfine watchexec tokei
  dust duf procs colima docker kubectl helm terraform ollama chezmoi
)
for tool in "${tools[@]}"; do show_command "$tool"; done

section "Provider and PATH resolution"
for tool in rustup rustc cargo rg jq emacs go node npm docker; do show_providers "$tool"; done

if command -v brew >/dev/null 2>&1; then
  section "Known coexistence checks"
  brew_has_formula rust && echo "NOTICE: Homebrew rust is installed; preserve it, but prefer ~/.cargo/bin from official rustup."
  brew_has_formula emacs && echo "OK: Homebrew emacs formula installed."
  brew_has_cask emacs-app && echo "OK: emacs-app cask installed; preserve alongside formula Emacs."
  brew_has_formula colima && echo "OK: Colima installed."
  brew_has_cask orbstack && echo "NOTICE: OrbStack exists; do not delete it without approval and do not reproduce it by default."
  if brew_has_formula ripgrep; then
    brew_rg="$(brew --prefix)/bin/rg"
    active_rg="$(command -v rg 2>/dev/null || true)"
    [[ "$active_rg" == "$brew_rg" ]] || echo "NOTICE: Homebrew ripgrep is installed but active rg is '$active_rg'; prefer a PATH fix, not deletion."
  fi
fi

section "Global npm packages"
if command -v npm >/dev/null 2>&1; then
  npm ls -g --depth=0 2>/dev/null || true
else
  echo "npm=MISSING"
fi

section "Language-managed tools"
command -v rustup >/dev/null 2>&1 && rustup show active-toolchain 2>/dev/null || true
command -v cargo >/dev/null 2>&1 && cargo install --list 2>/dev/null || true
command -v go >/dev/null 2>&1 && { go version; go env GOPATH GOROOT 2>/dev/null; } || true
command -v uv >/dev/null 2>&1 && uv tool list 2>/dev/null || true

section "Existing configuration"
paths=(
  "$HOME/.config/fish/config.fish"
  "$HOME/.config/fish/conf.d"
  "$HOME/.config/ghostty/config"
  "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  "$HOME/.gitconfig"
  "$HOME/.config/git/config"
  "$HOME/.tmux.conf"
  "$HOME/.config/tmux/tmux.conf"
  "$HOME/.emacs"
  "$HOME/.emacs.el"
  "$HOME/.emacs.d/init.el"
  "$HOME/.config/emacs/init.el"
)
for path in "${paths[@]}"; do [[ -e "$path" || -L "$path" ]] && ls -ld "$path"; done

section "Container status (no start)"
command -v colima >/dev/null 2>&1 && colima status 2>/dev/null || true
command -v docker >/dev/null 2>&1 && docker context show 2>/dev/null || true
