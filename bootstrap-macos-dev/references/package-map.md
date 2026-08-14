# macOS installation channel map

Prefer Homebrew unless the ecosystem's official mainstream workflow is more appropriate. Verify current formula, cask, and npm names before changing this map.

## Core and full profiles

| Capability | Preferred package/channel | Notes |
|---|---|---|
| Apple compiler, SDK, make, LLDB | Xcode Command Line Tools | Check with `xcode-select -p`; do not update macOS |
| Homebrew | Official Homebrew installer | Prefix is normally `/opt/homebrew` on Apple Silicon and `/usr/local` on Intel |
| Build tools | `cmake`, `ninja`, `pkg-config`, `bear` | Homebrew formulae |
| Git | `git`, `git-lfs`, `gh`, `lazygit` | Homebrew; `gh` and `lazygit` belong to broader profiles |
| Search and files | `ripgrep`, `fd`, `fzf`, `bat`, `eza`, `zoxide`, `tree`, `yazi` | Homebrew formulae |
| Data formats | system `jq`; Homebrew `yq` | Keep system `jq` unless a requirement needs a newer one |
| Shell and multiplexer | `fish`, `tmux` | Homebrew formulae |
| Terminal | `ghostty` | Homebrew cask |
| Emacs CLI | `emacs`, `libvterm` | Homebrew formulae |
| Emacs GUI | `emacs-app` | Homebrew cask; preserve alongside formula Emacs |
| Rust | official `rustup` | Do not install Homebrew `rust` on a fresh machine |
| Go toolchain | `go` | Homebrew on fresh Macs; preserve existing official installations |
| Go developer tools | `go install module@latest` | `gopls`, `dlv`, `benchstat`, `govulncheck`, `pprof` |
| Node/npm | `node` | Homebrew formula; npm is included |
| Python CLI manager | `uv` | Homebrew formula; use `uv tool install` where appropriate |
| Containers | `colima`, `docker` | Homebrew formulae; do not install OrbStack |

## Agent profile

| Capability | Preferred package/channel | Notes |
|---|---|---|
| Structured search | `ast-grep` | Homebrew formula when available |
| Task/environment | `just`, `direnv` | Homebrew formulae |
| Shell/YAML checks | `shellcheck`, `shfmt`, `actionlint`, `yq` | Homebrew formulae |
| Python quality/hooks | `ruff`, `pre-commit` | Prefer Homebrew where maintained; `uv tool install` is acceptable for isolated Python CLIs |
| Secrets | `age`, `sops` | Homebrew formulae |
| Supply chain | `trivy`, `syft`, `grype` | Homebrew formulae |
| HTTP/Markdown UX | `xh`, `glow` | Homebrew formulae |
| Benchmark/watch/count | `hyperfine`, `watchexec`, `tokei` | Homebrew formulae |
| Disk/process UX | `dust`, `duf`, `procs` | Homebrew formulae |
| Codex CLI | `npm install -g @openai/codex` | Opt-in; verify official package name |
| Gemini CLI | `npm install -g @google/gemini-cli` | Opt-in; verify official package name |
| Claude Code | `npm install -g @anthropic-ai/claude-code` | Opt-in; verify official package name |
| agent-browser | `npm install -g agent-browser` | Opt-in; verify project and package provenance |

## Explicit exclusions

- OrbStack: do not install because commercial use may require a paid license.
- Tencent-internal packages: detect and preserve, but never install by default.
- Homebrew `rust`: do not install on fresh machines; use official rustup.
- Blanket Homebrew upgrades: report outdated packages instead.
- Automatic uninstall, unlink, cleanup, migration, or dotfile replacement.
