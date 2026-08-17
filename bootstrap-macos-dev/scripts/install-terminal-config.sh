#!/usr/bin/env bash
set -euo pipefail

dry_run=0
assume_yes=0
force=0
skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fish_assets="$skill_dir/assets/fish"
ghostty_assets="$skill_dir/assets/ghostty"

usage() {
  cat <<'EOF'
usage: install-terminal-config.sh [--dry-run] [--yes] [--force]

Install the skill's portable Fish and Ghostty experience.
- Existing configs are never deleted.
- Without --force, any differing managed file causes the script to stop.
- With --force, differing managed files are backed up before replacement.
- Fisher plugins require network access.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --yes) assume_yes=1; shift ;;
    --force) force=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done
[[ "$(uname -s)" == Darwin ]] || { echo "This script supports macOS only." >&2; exit 1; }
command -v brew >/dev/null 2>&1 || { echo "Homebrew is required." >&2; exit 1; }
brew_prefix="$(brew --prefix)"
fish_bin="$brew_prefix/bin/fish"
[[ -x "$fish_bin" || $dry_run -eq 1 ]] || { echo "Homebrew Fish is required at $fish_bin." >&2; exit 1; }

confirm() {
  [[ $assume_yes -eq 1 ]] && return 0
  read -r -p "$1 [y/N] " answer
  [[ "$answer" == [yY] ]]
}
print_cmd() {
  printf '+'
  printf ' %q' "$@"
  printf '\n'
}
run() {
  print_cmd "$@"
  [[ $dry_run -eq 1 ]] || "$@"
}

timestamp="$(date +%Y%m%d-%H%M%S)"
backup_root="$HOME/.config/bootstrap-macos-dev-backups/$timestamp"
backed_up=0
conflicts=()
conflict_count=0

backup_file() {
  local target=$1 rel=$2 backup="$backup_root/$rel"
  [[ -e "$target" || -L "$target" ]] || return 0
  echo "BACKUP  $target -> $backup"
  if [[ $dry_run -eq 0 ]]; then
    mkdir -p "$(dirname "$backup")"
    cp -p "$target" "$backup"
  fi
  backed_up=1
}

check_file() {
  local source=$1 target=$2 rel=$3 mode=${4:-0644}
  if [[ -e "$target" || -L "$target" ]]; then
    if cmp -s "$source" "$target"; then
      return 0
    fi
    if [[ $force -ne 1 ]]; then
      conflicts+=("$target")
      conflict_count=$((conflict_count + 1))
    fi
  fi
}

install_file() {
  local source=$1 target=$2 rel=$3 mode=${4:-0644}
  if [[ -e "$target" || -L "$target" ]]; then
    if cmp -s "$source" "$target"; then
      echo "KEEP    $target (already matches)"
      return 0
    fi
    backup_file "$target" "$rel"
  fi
  echo "INSTALL $target"
  if [[ $dry_run -eq 0 ]]; then
    mkdir -p "$(dirname "$target")"
    install -m "$mode" "$source" "$target"
  fi
}

rendered_ghostty="$(mktemp)"
rendered_fish_paths="$(mktemp)"
trap 'rm -f "$rendered_ghostty" "$rendered_fish_paths"' EXIT
sed "s|__HOMEBREW_PREFIX__|$brew_prefix|g" "$ghostty_assets/config" > "$rendered_ghostty"
sed "s|__HOMEBREW_PREFIX__|$brew_prefix|g" "$fish_assets/homebrew-paths.fish" > "$rendered_fish_paths"

echo "This installs the originating workstation's portable terminal experience:"
echo "- Fish config with eza aliases"
echo "- portable Homebrew, Cargo, Go, and ~/.local PATH ordering"
echo "- Fisher plugins: Tide v6, fzf.fish, z, autopair, and zoxide.fish"
echo "- the captured Tide appearance/settings"
echo "- Ghostty Catppuccin Mocha, left Option as Meta, and layered cursor shaders"
echo "No existing file will be replaced unless --force is supplied."
[[ $dry_run -eq 1 ]] || confirm "Continue with terminal configuration installation?" || exit 0

fish_dir="$HOME/.config/fish"
ghostty_dir="$HOME/.config/ghostty"
ghostty_alt="$HOME/Library/Application Support/com.mitchellh.ghostty/config"

if [[ -f "$ghostty_alt" ]] && grep -Eq '^[[:space:]]*[^#[:space:]][^=]*=' "$ghostty_alt"; then
  echo "NOTICE: alternate Ghostty config contains active settings: $ghostty_alt"
  grep -E '^(command|theme|font-family|font-size|macos-option-as-alt|custom-shader|custom-shader-animation)[[:space:]]*=' "$ghostty_alt" || true
  if [[ $force -ne 1 ]]; then
    conflicts+=("$ghostty_alt (alternate active config; inspect effective layering)")
    conflict_count=$((conflict_count + 1))
  else
    echo "KEEP    $ghostty_alt (not managed or replaced by this script)"
  fi
fi

check_file "$fish_assets/config.fish" "$fish_dir/config.fish" "fish/config.fish"
check_file "$fish_assets/fish_plugins" "$fish_dir/fish_plugins" "fish/fish_plugins"
check_file "$rendered_fish_paths" "$fish_dir/conf.d/bootstrap-macos-dev-paths.fish" "fish/conf.d/bootstrap-macos-dev-paths.fish"
check_file "$rendered_ghostty" "$ghostty_dir/config" "ghostty/config"
check_file "$ghostty_assets/shaders/cursor_warp.glsl" "$ghostty_dir/shaders/cursor_warp.glsl" "ghostty/shaders/cursor_warp.glsl"
check_file "$ghostty_assets/shaders/cursor_frozen.glsl" "$ghostty_dir/shaders/cursor_frozen.glsl" "ghostty/shaders/cursor_frozen.glsl"

if [[ $conflict_count -gt 0 ]]; then
  echo "The following managed targets differ:"
  printf '  - %s\n' "${conflicts[@]}"
  echo "No files were changed. Review the differences, then rerun with --force to create backups and replace them."
  exit 2
fi

install_file "$fish_assets/config.fish" "$fish_dir/config.fish" "fish/config.fish"
install_file "$fish_assets/fish_plugins" "$fish_dir/fish_plugins" "fish/fish_plugins"
install_file "$rendered_fish_paths" "$fish_dir/conf.d/bootstrap-macos-dev-paths.fish" "fish/conf.d/bootstrap-macos-dev-paths.fish"
install_file "$rendered_ghostty" "$ghostty_dir/config" "ghostty/config"
install_file "$ghostty_assets/shaders/cursor_warp.glsl" "$ghostty_dir/shaders/cursor_warp.glsl" "ghostty/shaders/cursor_warp.glsl"
install_file "$ghostty_assets/shaders/cursor_frozen.glsl" "$ghostty_dir/shaders/cursor_frozen.glsl" "ghostty/shaders/cursor_frozen.glsl"

if [[ $backed_up -eq 1 ]]; then
  echo "Existing files were backed up under: $backup_root"
fi

fisher_function="$fish_dir/functions/fisher.fish"
if [[ ! -f "$fisher_function" ]]; then
  echo "Fisher is missing and must be installed from its official repository."
  if [[ $dry_run -eq 1 ]]; then
    echo "+ $fish_bin -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; fisher install jorgebucaran/fisher'"
  elif confirm "Download and install Fisher?"; then
    "$fish_bin" -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; fisher install jorgebucaran/fisher'
  else
    echo "Skipped Fisher; plugin installation and Tide configuration are incomplete."
    exit 0
  fi
fi

if [[ $dry_run -eq 1 ]]; then
  echo "+ $fish_bin -c 'fisher update'"
  echo "+ $fish_bin $fish_assets/tide-settings.fish"
else
  "$fish_bin" -c 'fisher update'
  "$fish_bin" "$fish_assets/tide-settings.fish"
fi

cat <<EOF

Terminal configuration installed.
- Ghostty config: $ghostty_dir/config
- Fish config: $fish_dir/config.fish
- Plugin manifest: $fish_dir/fish_plugins
- Restart Fish and Ghostty, or reload Ghostty's config.
- Changing the macOS login shell is intentionally a separate approval.
EOF
