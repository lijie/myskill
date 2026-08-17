if status is-interactive
# Commands to run in interactive sessions can go here
end

if type -q eza
    alias ls "eza --icons --color=always --git"
    alias ll "eza -l --icons --git"
    alias la "eza -la --icons --git"
end

