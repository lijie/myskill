---
name: bootstrap-macos-dev
description: Bootstrap, refresh, or audit a terminal-first macOS development workstation using Homebrew as the default package source, with Xcode Command Line Tools, a reproducible Fish/Tide/fzf shell experience, Ghostty Catppuccin styling and cursor shaders, tmux, CLI and GUI Emacs, current stable Rust and Go, Node/npm, Colima, modern command-line utilities, and coding-agent-oriented quality and security tools. Use when preparing a new Apple Silicon or Intel Mac, reproducing the originating Mac's terminal appearance and behavior, standardizing an existing Mac development environment, checking PATH/provider conflicts, or safely adding missing tools without deleting existing software. Exclude macOS/kernel upgrades, account login, credentials, and destructive cleanup unless separately requested.
---

# Bootstrap macOS Development Environment

Build a reproducible Homebrew-first macOS environment while preserving the machine's existing tools and configuration.

## Non-negotiable safety rules

- Run `scripts/audit.sh` before proposing or making changes.
- Never update macOS or its kernel. Do not invoke Software Update except to guide installation of Xcode Command Line Tools when they are missing.
- Never uninstall, unlink, overwrite, or replace an existing tool merely because another provider is preferred.
- Treat every deletion, `brew uninstall`, `brew unlink`, package-manager migration, and config replacement as a separate action requiring an explicit report and user approval.
- Prefer Homebrew for command-line tools and desktop applications available through a maintained formula or cask.
- Keep ecosystem-standard exceptions: official `rustup` for Rust, `go install` for Go developer utilities, `uv tool install` for appropriate Python CLIs, and npm for tools whose mainstream distribution channel is npm.
- Do not install Tencent-internal or other private-registry packages by default.
- Do not run a blanket `brew upgrade` by default. Install missing packages and report outdated packages separately.
- Back up existing Fish, Ghostty, Emacs, tmux, Git, and other dotfiles before changing them. Never silently replace configuration.
- Treat bundled Fish and Ghostty assets as managed configuration. If a target differs, stop and show the conflict; replace it only after explicit approval and a timestamped backup.
- Do not log in to GitHub, npm, container registries, AI services, or other accounts; do not create keys or tokens.
- Do not make Fish the login shell without explicit approval. Before `chsh`, add the Homebrew Fish path to `/etc/shells` if necessary and report that this requires elevated privileges.
- Preserve both Homebrew `emacs` and the `emacs-app` cask when present: they serve terminal and GUI use cases. Do not remove either to resolve a conflict without approval.
- Prefer official `rustup` toolchains over the Homebrew `rust` formula. Report a duplicate Homebrew Rust installation, but do not remove it.
- Keep Colima as the default container runtime. Do not install OrbStack.
- Keep a usable system `jq`; install Homebrew `jq` only when the system version is missing or insufficient for a stated requirement.
- Install Homebrew `ripgrep` and arrange interactive PATH so it wins over vendored copies, but do not delete vendored binaries.

## Workflow

### 1. Audit the Mac

Run:

```bash
scripts/audit.sh
```

Review:

- macOS version, architecture, Xcode Command Line Tools, Rosetta status, CPU, memory, and disk;
- Homebrew presence, prefix, health, installed formulae/casks, and outdated packages;
- current login shell, Fish installation, Ghostty configuration, and relevant dotfiles;
- language toolchains, editors, containers, npm globals, and common development commands;
- command-provider and PATH shadowing results, especially for `rustc`, `cargo`, `rg`, `jq`, `emacs`, `docker`, and `node`;
- coexistence of providers such as Rust formula plus rustup, Emacs formula plus app cask, or multiple container runtimes.

Do not interpret duplication as permission to clean up. Report it and continue non-destructively.

### 2. Choose a profile

Use:

```bash
scripts/bootstrap.sh --profile core|full|agent
```

- `core`: Xcode Command Line Tools check, Homebrew, build essentials, Git, and modern search/file/JSON utilities.
- `full`: `core` plus Fish, Ghostty, tmux, CLI and GUI Emacs, Rust prerequisites, Go, Node/npm, Colima/Docker CLI, language tooling, and terminal UX.
- `agent`: `full` plus GitHub, structured search, task/environment/hook, formatting/linting, secrets, SBOM, vulnerability, and coding-agent support tools.

The script installs only missing packages, never uninstalls packages, and does not run a blanket upgrade. Use `--dry-run` to inspect commands. Use `--yes` only after reviewing the plan.

For `full` and `agent`, apply the bundled terminal experience separately after package installation:

```bash
scripts/install-terminal-config.sh --dry-run
scripts/install-terminal-config.sh
```

Use `--force` only after reviewing differing target files. It backs up every replaced managed file under `~/.config/bootstrap-macos-dev-backups/<timestamp>/`.

Mainstream npm-distributed AI CLIs are opt-in even in the `agent` profile:

```bash
scripts/bootstrap.sh --profile agent --with-ai-cli
```

Before installing them, verify the current official npm package names. Never include private packages in this list.

### 3. Install Homebrew safely

If Homebrew is missing, use the official installer after displaying the exact command and obtaining approval. Then initialize it according to architecture:

```fish
# Apple Silicon
/opt/homebrew/bin/brew shellenv | source

# Intel
/usr/local/bin/brew shellenv | source
```

Persist the appropriate initialization in a dedicated Fish file such as `~/.config/fish/conf.d/homebrew.fish`, after backing up any existing file.

Run `brew doctor` and report warnings. Do not “fix” warnings by deleting files or unlinking packages without approval.

### 4. Configure Fish and Ghostty

Reproduce the originating Fish experience using the bundled assets:

- `assets/fish/config.fish`: interactive `eza` aliases for `ls`, `ll`, and `la`;
- `assets/fish/homebrew-paths.fish`: architecture-aware Homebrew initialization and stable user-tool PATH ordering;
- `assets/fish/fish_plugins`: Fisher, Tide v6, fzf.fish, z, autopair, and zoxide.fish;
- `assets/fish/tide-settings.fish`: portable Tide colors, icons, layout, transient prompt, language segments, and Colima-aware Docker context settings.

Install the plugin manifest through Fisher rather than copying generated plugin files. Do not copy `fish_variables`: it contains generated caches and machine-specific absolute paths. Apply only the curated universal variables from `tide-settings.fish`.

The current plugin set intentionally contains both `z` and `zoxide.fish`; zoxide wins the `z` function at runtime, matching the originating machine. Preserve this behavior for parity unless the user asks to simplify it.

The Tide prompt uses Powerline and Nerd Font glyphs. Ghostty's default macOS font fallback currently renders the originating setup; if glyphs are missing on another Mac, install a Nerd Font only after confirming the desired font and then set `font-family` explicitly.

Add Homebrew's `bin` and `sbin` ahead of package-vendored paths. Do not globally replace standard commands in scripts or non-interactive shells.

Install Ghostty through its Homebrew cask when absent. The bundled active configuration reproduces:

- Homebrew Fish as the spawned shell, with the architecture-specific Homebrew prefix rendered at installation time;
- the `Catppuccin Mocha` theme;
- left Option as Meta;
- two layered cursor shaders (`cursor_warp.glsl` and the customized `cursor_frozen.glsl`);
- continuous shader animation.

The shader assets live under `assets/ghostty/shaders/`; preserve `assets/ghostty/NOTICE.md` with their provenance.

Preserve and inspect both common configuration locations:

- `~/.config/ghostty/config`
- `~/Library/Application Support/com.mitchellh.ghostty/config`

Do not overwrite either silently. Ghostty can load both locations depending on version/history, which may layer duplicate shader settings. Use `ghostty +show-config` when available to inspect the effective configuration. The installer manages `~/.config/ghostty/config`; report the Application Support config separately and require approval before replacing or removing it.

If the Application Support config contains active settings, the terminal installer stops unless `--force` is supplied. Even with `--force`, it preserves that alternate file and reports it; inspect the effective result for duplicated or overridden settings.

### 5. Install language environments

#### Rust

Use official `rustup`, not `brew install rust`, for the active toolchain:

```bash
rustup toolchain install stable
rustup default stable
rustup component add rust-analyzer rust-src llvm-tools-preview clippy rustfmt
```

If the Homebrew Rust formula already exists, leave it installed and ensure interactive PATH resolves `rustc` and `cargo` to `~/.cargo/bin`. Any later removal requires separate approval.

Install Rust utilities with `cargo install --locked` when Homebrew is not the preferred maintained channel or when the tool is specifically Rust ecosystem tooling.

#### Go

Prefer Homebrew for the Go toolchain on a fresh Mac. Preserve an existing official `/usr/local/go` installation and report which `go` wins in PATH instead of replacing it.

Use `go install ...@latest` for Go ecosystem developer commands such as `gopls`, Delve, `benchstat`, `govulncheck`, and `pprof`.

#### Node and npm

Install Node with Homebrew. Use npm for CLIs whose official/mainstream install channel is npm. Do not configure registries, authenticate, or install private organization packages.

Use Corepack for pnpm or Yarn when the installed Node release supports it; otherwise ask before installing a global package manager.

#### Python

Install `uv` with Homebrew. Use `uv tool install` for Python CLI applications when that is their recommended isolation model. Do not mutate the system Python.

### 6. Configure editors and containers

Install both:

- `brew install emacs` for a terminal-oriented executable and Homebrew-managed libraries;
- `brew install --cask emacs-app` for the GUI application.

Preserve existing Emacs configuration and symlinks. Inspect configuration dependencies before batch-loading it.

Use Colima plus the Docker CLI for local containers. Do not install OrbStack. Start or alter Colima resources only after discussing CPU, memory, disk, architecture, and Kubernetes requirements.

### 7. Handle PATH and provider conflicts

Use `type -a`/`which -a` and `brew --prefix` to distinguish:

- desired Homebrew commands;
- Apple-provided system commands;
- language-manager commands;
- vendored commands embedded in npm or agent packages.

Prefer PATH fixes over deletion. In particular:

- resolve Rust to `~/.cargo/bin`;
- resolve `rg` to Homebrew's `bin/rg`;
- accept `/usr/bin/jq` when its functionality is sufficient;
- preserve both Emacs installations;
- resolve Docker commands to the Docker CLI while retaining Colima as the daemon/runtime.

Report every remaining ambiguity after configuration.

### 8. Validate

Run:

```bash
scripts/verify.sh --profile core|full|agent
```

Also:

- compile and execute a small C program with Apple Clang;
- build small Rust and Go programs when those toolchains are in the profile;
- start Fish non-interactively and inspect PATH/provider resolution;
- verify Fisher plugins, Tide prompt variables, eza aliases, and effective `z`/`zi` functions;
- inspect Ghostty's effective theme, shell, Option-key behavior, and both shader paths;
- run Emacs batch mode and identify the executable/provider;
- validate tmux config with an isolated server;
- run Colima/Docker checks without starting or reconfiguring Colima unless approved;
- smoke-check quality/security commands installed by the selected profile.

Distinguish sandbox, privacy, TCC, virtualization, and network restrictions from installation failures.

## References

Read [references/tool-catalog.md](references/tool-catalog.md) for profile membership, purpose, and preferred install channels.

Read [references/package-map.md](references/package-map.md) before translating capabilities into Homebrew formulae, casks, or ecosystem-specific commands.
