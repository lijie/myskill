# Package map

Package names vary by distribution. Search the package manager when a listed name is unavailable.

| Capability | DNF / RHEL-like examples | APT / Debian-like examples |
|---|---|---|
| Build essentials | `gcc gcc-c++ make cmake` or group `Development Tools` | `build-essential cmake` |
| Debug/profile | `gdb lldb perf valgrind strace` | `gdb lldb linux-tools-common valgrind strace` |
| Emacs terminal deps | `ncurses-devel gnutls-devel libxml2-devel jansson-devel sqlite-devel libacl-devel libgccjit-devel libtree-sitter-devel texinfo` | `libncurses-dev libgnutls28-dev libxml2-dev libjansson-dev libsqlite3-dev libacl1-dev libgccjit-*-dev libtree-sitter-dev texinfo` |
| vterm | `libvterm libvterm-devel` | `libvterm0 libvterm-dev` |
| LLVM C/C++ | `clang clang-tools-extra lldb` | `clang clangd clang-format clang-tools lldb` |
| Modern CLI | `fd-find ripgrep the_silver_searcher fzf eza zoxide ncdu duf jq git-delta procs` | `fd-find ripgrep silversearcher-ag fzf eza zoxide ncdu duf jq git-delta` |
| Shell/YAML | `ShellCheck yq` | `shellcheck`; install Mike Farah yq separately if Debian's `yq` is the Python wrapper |
| Build acceleration | `ccache mold bear` | `ccache mold bear` |
| Zsh/tmux | `zsh tmux` | `zsh tmux` |

On Debian systems, `fd-find` may expose `fdfind` rather than `fd`; add a user-level symlink only if needed.
