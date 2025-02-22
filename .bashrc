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

bind 'set show-mode-in-prompt off'

export PATH="$HOME/.emacs.d/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/devid/.lmstudio/bin"

[[ -s /etc/profile.d/autojump.sh ]] && source /etc/profile.d/autojump.sh

