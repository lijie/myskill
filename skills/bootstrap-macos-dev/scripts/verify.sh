#!/usr/bin/env bash
set -uo pipefail

profile=agent
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) profile=${2:?missing profile}; shift 2 ;;
    -h|--help) echo 'usage: verify.sh [--profile core|full|agent]'; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done
case "$profile" in core|full|agent) ;; *) echo "invalid profile: $profile" >&2; exit 2 ;; esac
[[ "$(uname -s)" == Darwin ]] || { echo "This script supports macOS only." >&2; exit 1; }

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:$PATH"
fail=0

check() {
  local name=$1
  if command -v "$name" >/dev/null 2>&1; then
    printf 'OK      %-18s %s\n' "$name" "$(command -v "$name")"
  else
    printf 'MISSING %-18s\n' "$name"
    fail=1
  fi
}
brew_has_formula() { grep -Fxq "$1" <<< "${BREW_FORMULAE:-}"; }
brew_has_cask() { grep -Fxq "$1" <<< "${BREW_CASKS:-}"; }

core=(clang make git cmake ninja pkg-config bear rg fd fzf bat eza zoxide yq)
full=(fish tmux emacs rustup rustc cargo rust-analyzer go gopls dlv node npm uv colima docker lazygit yazi)
agent=(gh ast-grep just direnv ruff pre-commit shellcheck shfmt actionlint age sops trivy syft grype xh glow hyperfine watchexec tokei dust duf procs)
tools=("${core[@]}")
[[ $profile == full || $profile == agent ]] && tools+=("${full[@]}")
[[ $profile == agent ]] && tools+=("${agent[@]}")

echo "=== Commands ($profile) ==="
for tool in "${tools[@]}"; do check "$tool"; done

echo "=== Homebrew ==="
if command -v brew >/dev/null 2>&1; then
  BREW_FORMULAE="$(brew list --formula 2>/dev/null || true)"
  BREW_CASKS="$(brew list --cask 2>/dev/null || true)"
  brew --version | head -n 1
  printf 'prefix=%s\n' "$(brew --prefix)"
  brew_has_formula ripgrep || { echo "MISSING Homebrew ripgrep formula"; fail=1; }
  active_rg="$(command -v rg 2>/dev/null || true)"
  expected_rg="$(brew --prefix)/bin/rg"
  if [[ "$active_rg" == "$expected_rg" ]]; then
    echo "OK      rg-provider        $active_rg"
  else
    echo "WARN    rg-provider        active=$active_rg expected=$expected_rg"
  fi
else
  echo "MISSING brew"
  fail=1
fi

echo "=== C smoke test ==="
tmpdir="$(mktemp -d)"
printf '#include <stdio.h>\nint main(void){puts("c-ok");}\n' > "$tmpdir/main.c"
clang -g "$tmpdir/main.c" -o "$tmpdir/main" && "$tmpdir/main" || fail=1
rm -rf "$tmpdir"

echo "=== jq ==="
if command -v jq >/dev/null 2>&1; then
  printf '{"ok":true}\n' | jq -e '.ok == true' >/dev/null && echo "OK      jq-functional      $(command -v jq)" || fail=1
else
  echo "MISSING jq"
  fail=1
fi

if [[ $profile == full || $profile == agent ]]; then
  echo "=== Rust provider and smoke test ==="
  rustc_path="$(command -v rustc 2>/dev/null || true)"
  case "$rustc_path" in
    "$HOME/.cargo/bin/"*) echo "OK      rust-provider      $rustc_path" ;;
    *) echo "WARN    rust-provider      expected official rustup under ~/.cargo/bin, got $rustc_path" ;;
  esac
  rust_tmp="$(mktemp -d)"
  printf 'fn main(){println!("rust-ok");}\n' > "$rust_tmp/main.rs"
  rustc -g "$rust_tmp/main.rs" -o "$rust_tmp/main" && "$rust_tmp/main" || fail=1
  rm -rf "$rust_tmp"

  echo "=== Go smoke test ==="
  go_tmp="$(mktemp -d)"
  printf 'package main\nimport "fmt"\nfunc main(){fmt.Println("go-ok")}\n' > "$go_tmp/main.go"
  go build -o "$go_tmp/main" "$go_tmp/main.go" && "$go_tmp/main" || fail=1
  rm -rf "$go_tmp"

  echo "=== Fish ==="
  fish -c 'printf "fish=%s\n" $version; type -a rg; type -a rustc' || fail=1
  [[ -f "$HOME/.config/fish/config.fish" ]] && fish -n "$HOME/.config/fish/config.fish" || true
  fish -ic '
    functions -q fisher
    and functions -q tide
    and functions -q fzf_configure_bindings
    and functions -q _autopair_backspace
    and functions -q __zoxide_z
    and type -q z
    and type -q zi
    and alias ls | string match -q "*eza*"
    and contains vi_mode $tide_left_prompt_items
    and contains git $tide_left_prompt_items
    and contains status $tide_right_prompt_items
    and contains time $tide_right_prompt_items
  ' || { echo "MISSING or mismatched bundled Fish experience"; fail=1; }

  echo "=== Ghostty experience ==="
  ghostty_bin="$(command -v ghostty 2>/dev/null || true)"
  [[ -n "$ghostty_bin" ]] || [[ ! -x /Applications/Ghostty.app/Contents/MacOS/ghostty ]] || ghostty_bin=/Applications/Ghostty.app/Contents/MacOS/ghostty
  if [[ -n "$ghostty_bin" ]]; then
    ghostty_effective="$("$ghostty_bin" +show-config 2>/dev/null || true)"
    grep -Fq 'theme = Catppuccin Mocha' <<< "$ghostty_effective" || { echo "MISMATCH Ghostty theme"; fail=1; }
    grep -Fq "command = $(brew --prefix)/bin/fish" <<< "$ghostty_effective" || { echo "MISMATCH Ghostty Fish command"; fail=1; }
    grep -Fq 'macos-option-as-alt = left' <<< "$ghostty_effective" || { echo "MISMATCH Ghostty Option/Meta setting"; fail=1; }
    grep -Fq "$HOME/.config/ghostty/shaders/cursor_warp.glsl" <<< "$ghostty_effective" || { echo "MISSING Ghostty warp shader"; fail=1; }
    grep -Fq "$HOME/.config/ghostty/shaders/cursor_frozen.glsl" <<< "$ghostty_effective" || { echo "MISSING Ghostty frozen shader"; fail=1; }
    grep -Fq 'custom-shader-animation = always' <<< "$ghostty_effective" || { echo "MISMATCH Ghostty shader animation"; fail=1; }
  else
    echo "MISSING Ghostty executable"
    fail=1
  fi

  echo "=== Emacs ==="
  emacs --batch -Q --eval '(princ (format "emacs=%s window-system=%S executable=%s\n" emacs-version window-system invocation-name))' || fail=1
  if command -v brew >/dev/null 2>&1; then
    brew_has_formula emacs || { echo "MISSING emacs formula"; fail=1; }
    brew_has_cask emacs-app || { echo "MISSING emacs-app cask"; fail=1; }
  fi

  echo "=== tmux ==="
  tmux_conf=()
  [[ -f "$HOME/.tmux.conf" ]] && tmux_conf=(-f "$HOME/.tmux.conf")
  [[ -f "$HOME/.config/tmux/tmux.conf" ]] && tmux_conf=(-f "$HOME/.config/tmux/tmux.conf")
  tmux "${tmux_conf[@]}" -L bootstrap-macos-verify start-server 2>/dev/null || true
  tmux -L bootstrap-macos-verify kill-server 2>/dev/null || true

  echo "=== Containers (no automatic start) ==="
  colima status 2>/dev/null || echo "INFO: Colima is installed but not running."
  docker context show 2>/dev/null || echo "INFO: Docker CLI cannot currently reach or identify a context."
fi

exit "$fail"
