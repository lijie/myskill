# Tool catalog

Install only the selected profile and requested optional components. Existing extra tools should be detected and preserved.

## Core profile

| Tool | Purpose | Preferred channel |
|---|---|---|
| Xcode Command Line Tools | Apple Clang, SDK, make, LLDB, headers | Apple installer |
| Homebrew | Primary macOS package manager | Official installer |
| Git | Version control | Homebrew |
| CMake / Ninja / pkg-config / Bear | Native build orchestration and compilation database generation | Homebrew |
| ripgrep / fd | Fast text and file search | Homebrew |
| fzf | Interactive fuzzy selection | Homebrew |
| bat / eza / tree | Terminal file display and navigation | Homebrew |
| zoxide | Frecency-based directory navigation | Homebrew |
| jq | JSON query and transformation | Keep system copy when sufficient |
| yq | YAML query and transformation | Homebrew |
| wget | Scriptable downloads when curl is not convenient | Homebrew |

## Full profile

| Tool | Purpose | Preferred channel |
|---|---|---|
| Fish | Interactive shell with bundled eza aliases and Fisher-managed Tide/fzf/autopair/z/zoxide experience | Homebrew plus `assets/fish/` |
| Ghostty | Native terminal emulator with bundled Catppuccin Mocha styling and layered cursor shaders | Homebrew cask plus `assets/ghostty/` |
| tmux | Persistent terminal multiplexer | Homebrew |
| Emacs | Terminal editor | Homebrew formula |
| Emacs.app | GUI editor | `emacs-app` cask |
| libvterm | Native Emacs terminal module support | Homebrew |
| Rust / Cargo | Rust toolchain and package manager | Official rustup |
| rust-analyzer / rustfmt / Clippy | Rust LSP, formatting, and linting | rustup components |
| Go | Go compiler and standard tools | Homebrew on fresh Macs |
| gopls / Delve | Go LSP and debugger | `go install` |
| Node / npm | JavaScript runtime and npm-distributed CLIs | Homebrew |
| uv | Python versions, environments, packages, scripts, and isolated tools | Homebrew |
| Colima | Open-source local container runtime | Homebrew |
| Docker CLI | Client for Colima's Docker daemon | Homebrew |
| lazygit | Git terminal UI | Homebrew |
| yazi | Terminal file manager | Homebrew |

## Agent profile

| Tool | Purpose | Preferred channel |
|---|---|---|
| GitHub CLI | Scriptable repositories, issues, PRs, Actions, and API | Homebrew; user authenticates |
| ast-grep | AST-aware structural search and rewrite | Homebrew |
| just | Stable repository task interface | Homebrew |
| direnv | Project-local environment loading | Homebrew |
| Ruff | Python linting and formatting | Homebrew or isolated uv tool |
| pre-commit | Cross-language Git hook manager | Homebrew or isolated uv tool |
| ShellCheck / shfmt | Shell analysis and formatting | Homebrew |
| actionlint | GitHub Actions workflow validation | Homebrew |
| age / SOPS | Encryption and structured secret files | Homebrew; do not create keys automatically |
| Trivy / Syft / Grype | Vulnerability scanning and SBOM generation | Homebrew |
| xh | Human-friendly HTTP client | Homebrew |
| glow | Terminal Markdown rendering | Homebrew |
| hyperfine | Statistical command benchmarking | Homebrew |
| watchexec | Re-run commands when files change | Homebrew |
| tokei | Source line counting | Homebrew |
| dust / duf / procs | Disk and process visualization | Homebrew |

## Optional mainstream npm CLI set

Install only with explicit opt-in and only after verifying official package names:

- OpenAI Codex CLI
- Google Gemini CLI
- Anthropic Claude Code
- agent-browser

Never infer that an existing private/internal npm package should be reproduced on another Mac.

## Bundled terminal experience

The skill carries portable, reviewed configuration assets rather than raw machine state:

- Fish's `config.fish`, portable Homebrew/user-tool PATH initialization, and `fish_plugins`;
- a curated Tide universal-variable script;
- Ghostty's active configuration template;
- the active `cursor_warp.glsl` and customized `cursor_frozen.glsl` shaders.

Do not bundle Fish's generated functions/completions, `fish_variables`, z/zoxide databases, Ghostty auto-theme state, or a nested shader Git repository. Recreate plugins from the manifest and copy only the active shader files.

## Existing-machine preferences worth preserving

An originating setup may include the following without making all of them universal defaults:

- `chezmoi` for dotfile management;
- `ollama` for local models;
- `openjdk` and `zig`;
- CopyQ or other GUI utilities;
- both Homebrew Emacs and Emacs.app;
- existing official Go under `/usr/local/go`;
- existing npm-distributed coding agents.

Audit and document these tools. Add them to an installation plan only when the user requests them or the target setup explicitly calls for parity.
