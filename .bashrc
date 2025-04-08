[[ $- != *i* ]] && return

if [ -f $HOME/.bash/prompt ]; then
	. $HOME/.bash/prompt
fi

if [ -f $HOME/.bash/aliases ]; then
	. $HOME/.bash/aliases
fi

if [ -f $HOME/.bash/functions ]; then
	. $HOME/.bash/functions
fi

if [ -f $HOME/.bash/exports ]; then
	. $HOME/.bash/exports
fi

if [ -f $HOME/.bash/paths ]; then
	. $HOME/.bash/paths
fi

if [ -f /etc/bash.command-not-found ]; then
    . /etc/bash.command-not-found
fi

eval "$(zoxide init bash)"

[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
