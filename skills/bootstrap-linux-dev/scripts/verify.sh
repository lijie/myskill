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
case "$profile" in core|full|agent) ;; *) echo "invalid profile: $profile" >&2; exit 2;; esac

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:/usr/local/go/bin:$PATH"
fail=0
check(){ local x=$1; if command -v "$x" >/dev/null 2>&1; then printf 'OK      %-18s %s\n' "$x" "$(command -v "$x")"; else printf 'MISSING %-18s\n' "$x"; fail=1; fi; }

core=(gcc g++ gdb make cmake git fd rg jq)
full=(emacs zsh tmux rustc cargo rust-analyzer go gopls dlv fzf bat eza zoxide)
agent=(gh ast-grep just direnv uv ruff pre-commit shellcheck shfmt actionlint yq trivy syft grype)
tools=("${core[@]}")
[[ $profile == full || $profile == agent ]] && tools+=("${full[@]}")
[[ $profile == agent ]] && tools+=("${agent[@]}")

echo "=== Commands ($profile) ==="
for x in "${tools[@]}"; do check "$x"; done

echo '=== C smoke test ==='
t=$(mktemp -d); printf '#include <stdio.h>\nint main(void){puts("c-ok");}\n' > "$t/a.c" && gcc -g "$t/a.c" -o "$t/a" && "$t/a" || fail=1; rm -rf "$t"

if [[ $profile == full || $profile == agent ]]; then
  echo '=== Emacs ==='
  emacs --batch -Q --eval '(princ (format "emacs=%s window-system=%S\n" emacs-version window-system))' || fail=1
  echo '=== Shell config syntax ==='
  [[ -f ~/.zshrc ]] && zsh -n ~/.zshrc || true
  [[ -f ~/.tmux.conf ]] && tmux -f ~/.tmux.conf -L skill-verify start-server 2>/dev/null || true
  tmux -L skill-verify kill-server 2>/dev/null || true
fi

exit "$fail"
