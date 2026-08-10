---
name: bootstrap-linux-dev
description: Bootstrap or refresh a terminal-first Linux development workstation/server with system updates, compiler/debugger tooling, current stable Rust and Go, CLI-only Emacs, Zsh/Oh My Zsh, tmux, modern search/file tools, LSP/DAP/profiling utilities, and coding-agent-oriented quality/security tools. Use when preparing a fresh Linux host, rebuilding a remote development server, standardizing a developer environment, or auditing/upgrading an existing setup. Exclude SSH key/login setup unless separately requested.
---

# Bootstrap Linux Development Environment

Build a reproducible terminal-first environment while preserving existing user configuration and verifying each layer before continuing.

## Safety rules

- Detect the distribution and package manager before installing anything.
- Prefer distro packages for system libraries and build dependencies.
- For fast-moving developer tools, verify the current stable release from official sources before installing.
- Use official release archives, official install scripts, `rustup`, `go install`, `cargo install --locked`, or `uv tool install` as appropriate.
- Verify checksums or signatures when the publisher provides them.
- Back up existing dotfiles before replacing them. Never overwrite an existing config silently.
- Keep user tools in `~/.local/bin`, `~/.cargo/bin`, or `~/go/bin`; reserve `/usr/local` for intentionally system-wide source installs.
- Do not globally enable behavior-changing optimizations such as `mold`, `ccache`, hooks, or project environment files without user approval.
- Do not run `gh auth login`, create encryption keys, or authorize `.envrc` files on the user's behalf.
- Treat `sudo reboot` as a separate, explicit action. Report when a new kernel or core libraries require it.

## Workflow

### 1. Audit the host

Run `scripts/audit.sh` first. Review:

- `/etc/os-release`, architecture, kernel, package manager;
- available privilege path (`sudo`, root, or neither);
- existing compilers, shells, editors, language toolchains, and CLI tools;
- disk, memory, and current PATH;
- existing `~/.emacs`, `~/.zshrc`, `~/.tmux.conf`, and related config.

If the host is not a supported DNF/APT Linux system, adapt the package list manually instead of forcing the script.

### 2. Choose a profile

Use `scripts/bootstrap.sh --profile core|full|agent`:

- `core`: system update, compiler/debugger basics, common CLI search/file tools.
- `full`: `core` plus Rust, Go, CLI Emacs build dependencies, Zsh, tmux, LSP/debug/profile tools.
- `agent`: `full` plus GitHub, structured search, format/lint, task, environment, hook, secrets, SBOM, vulnerability, and terminal UX tools.

The script intentionally installs package-manager prerequisites and stable package names only. It prints follow-up commands for release-sensitive tools rather than guessing stale versions.

### 3. Install language toolchains

#### Rust

Use official `rustup` with the `stable` channel. Add:

```bash
rustup component add rust-analyzer rust-src llvm-tools-preview clippy rustfmt
```

Install user-level utilities with locked Cargo resolution when possible:

```bash
cargo install --locked flamegraph cargo-llvm-cov cargo-audit cargo-bloat cargo-expand
```

Install CodeLLDB from its official Linux release asset into `~/.local/opt/codelldb`, exposing `~/.local/bin/codelldb`. Do not assume it is a crates.io package.

#### Go

Resolve the latest stable version from the official Go downloads JSON, download the matching archive, verify SHA-256, and install to `/usr/local/go`. Add `/usr/local/go/bin` and `~/go/bin` to PATH.

Install:

```bash
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/perf/cmd/benchstat@latest
go install golang.org/x/vuln/cmd/govulncheck@latest
go install github.com/google/pprof@latest
```

### 4. Build CLI-only Emacs

Verify the latest stable Emacs release from GNU. Download the tarball, signature, and GNU Emacs Group Release Keyring; verify the signature before building.

Configure with no graphical stack and retain useful terminal/development features:

```bash
./configure \
  --prefix=/usr/local \
  --without-x --without-x-toolkit \
  --without-xpm --without-jpeg --without-png --without-gif \
  --without-tiff --without-webp --without-rsvg --without-imagemagick \
  --without-sound --without-dbus --without-gsettings --without-gconf \
  --without-libsystemd --without-cairo --without-harfbuzz \
  --without-libotf --without-m17n-flt \
  --with-native-compilation=aot --with-tree-sitter \
  --with-xml2 --with-gnutls --with-sqlite3
```

Build with a reasonable parallelism cap, install under `/usr/local`, and verify `window-system=nil` plus the absence of X/GTK/Wayland dynamic dependencies.

When applying a remote Emacs config:

1. Inspect it for package archives, `use-package`, VC packages, hard-coded paths, and native module dependencies.
2. Back up existing init files.
3. Install the config.
4. Run an explicit batch load to install dependencies and catch errors.
5. Build native modules such as `vterm-module.so` if required.

### 5. Configure shell and tmux

Install Zsh and Oh My Zsh from the official repository. Preserve Rust, Go, Node, `~/.local/bin`, and Emacs paths.

Use `direnv` as the default project environment tool and `pre-commit` as the default cross-language Git hook framework when a choice is required.

If `chsh` cannot modify a remote NSS/LDAP/TJJ account, do not edit identity databases directly. Instead, make interactive Bash login shells `exec /usr/bin/zsh -l`, while leaving non-interactive SSH/SCP commands unaffected.

Install tmux and validate its config with an isolated server. If using a custom prefix, verify both the new prefix and the old prefix unbinding. Set a practical scrollback such as:

```tmux
set-option -g history-limit 50000
```

### 6. Configure modern CLI integrations

Useful Zsh integrations include:

```zsh
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
```

Optionally configure `fzf` to use `fd` and `bat`, Broot's `br` shell function, and Git's pager to `delta`. Avoid replacing standard commands globally in non-interactive shells.

### 7. Validate

Run `scripts/verify.sh`. Also verify:

- compile and execute a small C program;
- build a small Rust project with debug info and run `cargo llvm-cov`;
- build a small Go program with debug info;
- start Delve and CodeLLDB briefly where ptrace/socket policy allows;
- run `perf stat true`;
- run Emacs batch mode and ensure it finds LSP/debug/search tools;
- start an isolated tmux server and inspect effective options;
- start a Zsh login shell and inspect PATH;
- run smoke checks for `yq`, ShellCheck, `ast-grep`, `just`, Ruff, `actionlint`, and `shfmt`.

Distinguish sandbox restrictions from real installation failures. Retry ptrace, socket, or network validation outside a restricted sandbox only with approval.

## References

Read [references/tool-catalog.md](references/tool-catalog.md) for every installed tool's purpose, install channel, and important notes.

Read [references/package-map.md](references/package-map.md) when translating package names across DNF and APT systems.
