# ── Plugins (native, via Homebrew) ────────────────────────────────────────────
# zsh-completions: extend fpath before compinit (runs later in this file)
fpath=(/opt/homebrew/share/zsh-completions $fpath)

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# history-substring-search must be sourced AFTER syntax highlighting
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down


# ── Homebrew (static) ─────────────────────────────────────────────────────────
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
export HISTORY_SUBSTRING_SEARCH_PREFIXED=1

# ── Source local config files ─────────────────────────────────────────────────
for file in ~/.zsh/{exports,aliases,functions}.zsh; do
  [[ -r "$file" && -f "$file" ]] && source "$file"
done
unset file

# ── PATH ──────────────────────────────────────────────────────────────────────
NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$PATH:$NPM_PACKAGES/bin"
export MANPATH="${MANPATH:-}:$NPM_PACKAGES/share/man"
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="$HOME/.yarn/bin:$PATH"
export PATH="$HOME/.config/phpmon/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"


# ── SSH ───────────────────────────────────────────────────────────────────────
ssh-add -l &>/dev/null || (ssh-add --apple-use-keychain 2>/dev/null &)

# ── NVM (lazy-loaded) ─────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
nvm()  { unfunction nvm node npm; source "$NVM_DIR/nvm.sh"; nvm "$@" }
node() { unfunction nvm node npm; source "$NVM_DIR/nvm.sh"; node "$@" }
npm()  { unfunction nvm node npm; source "$NVM_DIR/nvm.sh"; npm "$@" }

# ── Ctrl+R prefix search ──────────────────────────────────────────────────────
fzf-history-prefix-search() {
  local prefix="${LBUFFER}"
  LBUFFER="$(fc -ln 1 | awk -v p="$prefix" '$0 ~ "^" p' | \
    fzf --tac --no-sort --height=40% --query="$prefix" \
        --bind=ctrl-r:toggle-sort)"
  zle reset-prompt
}
zle -N fzf-history-prefix-search
bindkey '^R' fzf-history-prefix-search
bindkey '^F' fzf-cd-widget

# ── Tool initialisers (cached) ────────────────────────────────────────────────
_cache_eval() {
  local name="$1"; shift
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/${name}.zsh"
  if [[ ! -f "$cache" ]]; then
    mkdir -p "${cache:h}"
    "$@" > "$cache" 2>/dev/null
  fi
  source "$cache"
}
# ── Completions (eager) ───────────────────────────────────────────────────────

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

autoload -Uz compinit && compinit -C

eval "$(zoxide init --cmd z zsh)"

# ── Tool initialisers (cached) ────────────────────────────────────────────────
_cache_eval "fnm"      fnm env --use-on-cd
_cache_eval "fzf"      fzf --zsh
_cache_eval "starship" starship init zsh
