#!/usr/bin/env bash
set -euo pipefail

profile=core
assume_yes=0
dry_run=0
with_ai_cli=0

usage() {
  cat <<'EOF'
usage: bootstrap.sh [--profile core|full|agent] [--dry-run] [--yes] [--with-ai-cli]

Installs missing software only. It never uninstalls packages and never runs brew upgrade.
--with-ai-cli is valid with the agent profile and installs verified mainstream npm CLIs.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) profile=${2:?missing profile}; shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    --yes) assume_yes=1; shift ;;
    --with-ai-cli) with_ai_cli=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done
case "$profile" in core|full|agent) ;; *) echo "invalid profile: $profile" >&2; exit 2 ;; esac
[[ $with_ai_cli -eq 0 || $profile == agent ]] || { echo "--with-ai-cli requires --profile agent" >&2; exit 2; }
[[ "$(uname -s)" == Darwin ]] || { echo "This script supports macOS only." >&2; exit 1; }

confirm() {
  [[ $assume_yes -eq 1 ]] && return 0
  read -r -p "$1 [y/N] " answer
  [[ "$answer" == [yY] ]]
}
run() {
  printf '+'
  printf ' %q' "$@"
  printf '\n'
  [[ $dry_run -eq 1 ]] || "$@"
}
brew_has_formula() { grep -Fxq "$1" <<< "$BREW_FORMULAE"; }
brew_has_cask() { grep -Fxq "$1" <<< "$BREW_CASKS"; }

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Xcode Command Line Tools are missing."
  echo "Run 'xcode-select --install' in an interactive macOS session, finish installation, then rerun this script."
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  installer='/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  echo "Homebrew is missing. Official installer command:"
  echo "$installer"
  [[ $dry_run -eq 1 ]] && exit 0
  confirm "Run the official Homebrew installer?" || exit 0
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "Homebrew installation completed but brew is not in an expected location." >&2
    exit 1
  fi
fi

core_formulae=(
  git git-lfs cmake ninja pkgconf bear wget
  ripgrep fd fzf bat eza zoxide tree yq
)
full_formulae=(
  fish tmux emacs libvterm go node uv colima docker lazygit yazi
)
full_casks=(ghostty emacs-app)
agent_formulae=(
  gh ast-grep just direnv ruff pre-commit shellcheck shfmt actionlint
  age sops trivy syft grype xh glow hyperfine watchexec tokei dust duf procs
)

BREW_FORMULAE="$(brew list --formula 2>/dev/null || true)"
BREW_CASKS="$(brew list --cask 2>/dev/null || true)"
formulae=("${core_formulae[@]}")
if [[ $profile == full || $profile == agent ]]; then
  formulae+=("${full_formulae[@]}")
fi
[[ $profile == agent ]] && formulae+=("${agent_formulae[@]}")

missing_formulae=()
missing_casks=()
for package in "${formulae[@]}"; do
  if [[ "$package" == go ]] && command -v go >/dev/null 2>&1 && ! brew_has_formula go; then
    echo "NOTICE: an existing non-Homebrew Go toolchain is active at $(command -v go); preserve it and skip duplicate Homebrew Go installation."
    continue
  fi
  brew_has_formula "$package" || missing_formulae+=("$package")
done
if [[ $profile == full || $profile == agent ]]; then
  for package in "${full_casks[@]}"; do
    if [[ "$package" == ghostty && -d /Applications/Ghostty.app ]]; then
      echo "NOTICE: /Applications/Ghostty.app already exists outside Homebrew management; preserve it and skip duplicate cask installation."
      continue
    fi
    brew_has_cask "$package" || missing_casks+=("$package")
  done
fi

echo "Profile: $profile"
echo "Homebrew prefix: $(brew --prefix)"
printf 'Missing formulae: %s\n' "${missing_formulae[*]:-(none)}"
printf 'Missing casks: %s\n' "${missing_casks[*]:-(none)}"
echo "No package will be removed, unlinked, or upgraded by this script."

missing_formula_count=${#missing_formulae[@]}
missing_cask_count=0
[[ $profile == full || $profile == agent ]] && missing_cask_count=${#missing_casks[@]}
if [[ $missing_formula_count -gt 0 || $missing_cask_count -gt 0 ]]; then
  if [[ $dry_run -eq 1 ]] || confirm "Install the listed missing Homebrew packages?"; then
    [[ $missing_formula_count -eq 0 ]] || run brew install "${missing_formulae[@]}"
    [[ $missing_cask_count -eq 0 ]] || run brew install --cask "${missing_casks[@]}"
  fi
fi

if [[ $profile == full || $profile == agent ]]; then
  if ! command -v rustup >/dev/null 2>&1; then
    echo "Official rustup is missing. The skill requires the official rustup installer, not Homebrew rust."
    rustup_cmd='curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh'
    echo "$rustup_cmd"
    if [[ $dry_run -eq 0 ]] && confirm "Run the official rustup installer?"; then
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    fi
  fi

  if [[ -x "$HOME/.cargo/bin/rustup" ]]; then
    run "$HOME/.cargo/bin/rustup" toolchain install stable
    run "$HOME/.cargo/bin/rustup" default stable
    run "$HOME/.cargo/bin/rustup" component add rust-analyzer rust-src llvm-tools-preview clippy rustfmt
  fi

  if command -v go >/dev/null 2>&1; then
    go_tools=(
      golang.org/x/tools/gopls@latest
      github.com/go-delve/delve/cmd/dlv@latest
      golang.org/x/perf/cmd/benchstat@latest
      golang.org/x/vuln/cmd/govulncheck@latest
      github.com/google/pprof@latest
    )
    if [[ $dry_run -eq 1 ]] || confirm "Install/update the standard Go developer tools in GOPATH/bin?"; then
      for tool in "${go_tools[@]}"; do run go install "$tool"; done
    fi
  fi
fi

if [[ $with_ai_cli -eq 1 ]]; then
  command -v npm >/dev/null 2>&1 || { echo "npm is required for --with-ai-cli." >&2; exit 1; }
  npm_packages=(
    @openai/codex
    @google/gemini-cli
    @anthropic-ai/claude-code
    agent-browser
  )
  echo "Opt-in mainstream npm packages: ${npm_packages[*]}"
  echo "Verify package provenance and current official package names before continuing."
  if [[ $dry_run -eq 1 ]] || confirm "Install these npm packages globally?"; then
    run npm install -g "${npm_packages[@]}"
  fi
fi

cat <<EOF

Installation pass complete.
- No packages were removed, unlinked, cleaned, or blanket-upgraded.
- For full/agent terminal parity, review and run scripts/install-terminal-config.sh --dry-run.
- Run scripts/audit.sh and scripts/verify.sh --profile $profile.
- The terminal-config installer stops on conflicts unless --force is explicitly supplied; forced replacements are backed up.
- Changing the login shell, starting/reconfiguring Colima, and any cleanup require separate approval.
EOF
