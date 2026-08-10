#!/usr/bin/env bash
set -uo pipefail

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:/usr/local/go/bin:$PATH"

echo '=== OS ==='
cat /etc/os-release 2>/dev/null || true
uname -a

echo '=== Resources ==='
nproc 2>/dev/null || true
free -h 2>/dev/null || true
df -h / /tmp 2>/dev/null | awk '!seen[$0]++'

echo '=== Identity/privilege ==='
id
command -v sudo >/dev/null && { sudo -n true 2>/dev/null && echo sudo_noninteractive=yes || echo sudo_noninteractive=no; }

echo '=== Package managers ==='
for x in dnf yum apt-get zypper pacman apk; do command -v "$x" 2>/dev/null || true; done

echo '=== Tool inventory ==='
tools=(gcc g++ clang clangd clang-format gdb lldb make cmake git emacs zsh tmux rustup rustc cargo rust-analyzer go gopls dlv fd rg ag fzf bat eza zoxide broot gh ast-grep just direnv uv ruff pre-commit shellcheck shfmt actionlint yq trivy syft grype)
for x in "${tools[@]}"; do
  if command -v "$x" >/dev/null 2>&1; then printf '%-18s %s\n' "$x" "$(command -v "$x")"; else printf '%-18s MISSING\n' "$x"; fi
done

echo '=== Existing config ==='
for p in ~/.emacs ~/.emacs.el ~/.emacs.d/init.el ~/.config/emacs/init.el ~/.zshrc ~/.zprofile ~/.zshenv ~/.tmux.conf ~/.config/tmux/tmux.conf; do [ -e "$p" ] && ls -ld "$p"; done
