ZSH=$HOME/.oh-my-zsh
ZSH_CUSTOM=$HOME/.zsh/zsh-custom
ZSH_THEME="agnoster"
AGNOSTER_DIR_FG=black

# Hide username in prompt
DEFAULT_USER=`whoami`

plugins=()

source $ZSH/oh-my-zsh.sh

eval $(/opt/homebrew/bin/brew shellenv)

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
export XDG_CONFIG_HOME="/Users/hasse/.config"

# Enable autosuggestions (installed via brew)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Extra paths
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/.yarn/bin:$PATH"
export PATH=$HOME/bin:~/.config/phpmon/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"

eval "$(zoxide init zsh)"
eval "$(fnm env --use-on-cd)"
eval "$(fzf --zsh)"
