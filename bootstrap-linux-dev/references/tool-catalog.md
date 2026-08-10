# Tool catalog

This catalog documents the environment assembled by this skill. Install only the profile and tools the user needs.

## Base system and compilation

| Tool/package | Purpose | Preferred channel |
|---|---|---|
| GCC / G++ | C and C++ compiler toolchain | Distro package |
| Make / CMake | Build orchestration and CMake projects | Distro package |
| Binutils | Linker, assembler, object inspection | Distro package |
| GDB | Source-level native debugger | Distro package |
| LLDB | LLVM native debugger; useful for Rust/C/C++ | Distro package |
| Clang / clangd / clang-format | C/C++ compiler, LSP, and formatter | Distro package |
| Bear | Generate `compile_commands.json` from Make builds | Distro package |
| ccache | Cache repeated C/C++ compilations | Distro package; opt in per project |
| mold | Fast ELF linker | Distro package; opt in per project |
| Valgrind | Memory errors, leaks, and profiling | Distro package |
| perf | Linux performance counters and sampling profiler | Kernel-matched distro package |
| strace | Trace system calls | Distro package |
| elfutils / libunwind | Native symbol and stack-unwind support | Distro package |
| pkg-config | Discover native library compiler/linker flags | Distro package |

## Languages, editor, and terminal

| Tool | Purpose | Preferred channel |
|---|---|---|
| Rust / Cargo / rustup | Rust compiler, package manager, toolchain manager | Official rustup |
| rust-analyzer | Rust LSP for Emacs and other editors | rustup component |
| rust-src | Standard library source for navigation/analysis | rustup component |
| rustfmt / Clippy | Rust formatting and linting | rustup components |
| llvm-tools-preview | LLVM coverage/profiling utilities for Rust | rustup component |
| CodeLLDB | DAP adapter for Rust/C/C++ debugging | Official GitHub release |
| cargo-flamegraph | Rust/Linux flame graphs using perf | crates.io |
| cargo-llvm-cov | Rust source coverage reports | crates.io |
| cargo-audit | Audit Cargo dependencies against RustSec | crates.io |
| cargo-bloat | Analyze Rust binary size | crates.io |
| cargo-expand | Expand Rust macros | crates.io |
| Go | Go compiler and standard tooling | Official go.dev archive + checksum |
| gopls | Go LSP | `go install` |
| Delve (`dlv`) | Go debugger and DAP server | `go install` |
| benchstat | Compare Go benchmark results statistically | `go install` |
| govulncheck | Find reachable known vulnerabilities in Go code | `go install` |
| pprof | Analyze Go CPU, heap, mutex, block, and custom profiles | `go install` |
| Emacs CLI | Terminal editor with native compilation, Tree-sitter, GnuTLS, XML, SQLite | Verified GNU source build |
| vterm | Native terminal emulator inside Emacs | ELPA/MELPA + libvterm native module |
| Zsh | Interactive shell | Distro package |
| Oh My Zsh | Zsh configuration/plugin framework | Official Git repository |
| tmux | Persistent terminal multiplexer | Distro package |

## Search, files, navigation, and terminal UX

| Tool | Purpose | Preferred channel |
|---|---|---|
| fd | Fast, user-friendly `find` replacement | Distro package |
| ripgrep (`rg`) | Very fast recursive text/regex search | Distro package |
| Silver Searcher (`ag`) | Alternative fast code searcher | Distro package |
| fzf | Interactive fuzzy selection | Distro package |
| ast-grep | AST-aware structural code search and rewrite | crates.io or official release |
| bat | Syntax-highlighted `cat`/file preview | crates.io or distro package |
| eza | Modern `ls` with Git metadata and trees | Distro package |
| zoxide | Frecency-based directory jumping | Distro package |
| broot | Interactive tree browser and directory launcher | crates.io |
| sd | Simpler find-and-replace alternative to common `sed` uses | crates.io |
| dust | Readable directory size visualization | crates.io |
| dua | Fast disk-usage analysis and interactive cleanup | crates.io |
| ncdu | Terminal disk-usage browser | Distro package |
| duf | Readable filesystem free-space display | Distro package |
| procs | Modern process listing | Distro package |
| jq / yq | Query and transform JSON / YAML | Distro package |
| delta | Syntax-highlighted Git diff pager | Distro package or official release |
| tokei | Count source lines by language | crates.io |
| hyperfine | Statistical command benchmark runner | crates.io |
| watchexec | Re-run commands when files change | crates.io |
| glow | Render Markdown in the terminal | Official release or `go install` |
| lazygit | Git TUI; complements Magit and plain Git | Official release or `go install` |
| xh | Friendly HTTP client for humans | Official release |

## Coding-agent and quality tooling

| Tool | Purpose | Preferred channel |
|---|---|---|
| GitHub CLI (`gh`) | Scriptable repositories, issues, PRs, Actions, and API access | Official release; user performs auth |
| just | Repository task runner; gives humans and agents one stable command interface | crates.io |
| direnv | Load project-specific environment variables on directory entry | Official release |
| pre-commit | Mainstream cross-language Git hook manager | `uv tool install` |
| uv / uvx | Fast Python version, environment, package, script, and CLI tool management | Official Astral installer |
| Ruff | Fast Python linting and formatting | `uv tool install` |
| ShellCheck | Shell script static analysis | Distro package |
| shfmt | Shell script formatter | `go install` or official release |
| actionlint | Validate GitHub Actions workflows | `go install` or official release |
| AGENTS.md | Repository instructions for coding agents: build, test, style, boundaries | Project file, not a package |
| justfile | Machine-readable project command entry points | Project file |

## Secrets and supply chain

| Tool | Purpose | Preferred channel |
|---|---|---|
| age / age-keygen | Simple modern file encryption and key generation | Official release or `go install` |
| SOPS | Encrypt selected values in YAML/JSON/ENV using age/KMS/PGP | Official release or `go install` |
| Trivy | Scan filesystems, images, dependencies, secrets, and IaC | Official release |
| Syft | Generate SBOMs from directories and container images | Official release |
| Grype | Scan images, filesystems, and SBOMs for vulnerabilities | Official release |
| git-lfs | Store large Git objects outside normal Git history | Distro package |

## Configuration sources used in the originating setup

These are optional user preferences, not universal defaults:

- A remote `.emacs.optimized` was installed as `~/.emacs` after inspection and dependency validation.
- A matching `google-c-style.el` was installed under `~/.lijie` because the Emacs config referenced it.
- A tmux config changed prefix from `C-b` to `C-l` and set `history-limit 50000`.
- Zsh aliases mapped `ls` to eza, `cat` to bat, and `grep` to rg. Apply aliases only when the user wants them.
