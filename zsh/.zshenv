# ~/.zshenv — sourced by EVERY zsh: interactive, non-interactive, scripts, and
# anything that shells out. Keep it small and side-effect free.
#
# EDITOR belongs here, not in .zshrc/exports.zsh: tools that spawn $EDITOR
# (git, crontab, sudo -e, fzf, ...) often run a non-interactive shell, which
# never reads .zshrc. The `alias vim=nvim` in aliases.zsh has the same gap —
# aliases only exist in interactive shells, so those callers fell through to
# /usr/bin/vim (no config, no treesitter, no Nord).
export EDITOR="nvim"
export VISUAL="$EDITOR"

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
