# Keep Homebrew and user-managed development tools ahead of vendored binaries.
if test -x __HOMEBREW_PREFIX__/bin/brew
    __HOMEBREW_PREFIX__/bin/brew shellenv | source
end

fish_add_path --prepend "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/go/bin"
