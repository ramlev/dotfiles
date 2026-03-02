ZSH=$HOME/.oh-my-zsh
ZSH_CUSTOM=$HOME/.zsh/zsh-custom
ZSH_THEME="agnoster"
AGNOSTER_DIR_FG=black

# Hide username in prompt
DEFAULT_USER=`whoami`

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git composer macos docker-compose fzf)

source $ZSH/oh-my-zsh.sh

eval $(/opt/homebrew/bin/brew shellenv)

# Removed old RVM path
#set numeric keys
# 0 . Enter
bindkey -s "^[Op" "0"
bindkey -s "^[Ol" "."
bindkey -s "^[OM" "^M"
# 1 2 3
bindkey -s "^[Oq" "1"
bindkey -s "^[Or" "2"
bindkey -s "^[Os" "3"
# 4 5 6
bindkey -s "^[Ot" "4"
bindkey -s "^[Ou" "5"
bindkey -s "^[Ov" "6"
# 7 8 9
bindkey -s "^[Ow" "7"
bindkey -s "^[Ox" "8"
bindkey -s "^[Oy" "9"
# + -  * /
bindkey -s "^[Ok" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"

# Load the shell dotfiles, and then some:
# * ~/.dotfiles-custom can be used for other settings you don’t want to commit.
for file in ~/.zsh/{exports,aliases,functions}.zsh; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done

unset file

# Sudoless npm https://github.com/sindresorhus/guides/blob/master/npm-global-without-sudo.md
NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$PATH:$NPM_PACKAGES/bin"
# Preserve MANPATH if you already defined it somewhere in your config.
# Otherwise, fall back to `manpath` so we can inherit from `/etc/manpath`.
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"

export PATH=$HOME/.bin:$PATH

# Import ssh keys in keychain
ssh-add --apple-use-keychain 2>/dev/null;

# Setup xdebug
export XDEBUG_CONFIG="idekey=PHPSTORM"

# Enable autosuggestions (installed via brew)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# Extra paths
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/.yarn/bin:$PATH"
export PATH=$HOME/bin:~/.config/phpmon/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"

# Initialize modern tools
# zoxide - smarter cd
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# fnm - Node.js version manager
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd)"
fi
