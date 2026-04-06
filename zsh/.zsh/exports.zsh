# Make vim the default editor
export EDITOR="nvim"

# ── Environment ───────────────────────────────────────────────────────────────
export XDG_CONFIG_HOME="/Users/hasse/.config"
export XDEBUG_CONFIG="idekey=PHPSTORM"

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups
# Make some commands not show up in history
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"
# And include the parameter for ZSH
export HISTORY_IGNORE="(ls|cd|cd -|pwd|exit|date|* --help)"

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS

# Prefer US English and use UTF-8
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
export FZF_DEFAULT_OPTS="
  --height 40%
  --border=rounded
  --prompt='❯ '
  --pointer='▶'
  --marker='✓'
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
"

export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window=down:3:wrap
"

export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons {}'"

# Highlight section titles in manual pages (bold yellow)
export LESS_TERMCAP_md=$'\e[1;33m'
export LESS_TERMCAP_me=$'\e[0m'

# Don't clear the screen after quitting a manual page
export MANPAGER="less -X"

# Do not auto update brew
export HOMEBREW_NO_AUTO_UPDATE=1
