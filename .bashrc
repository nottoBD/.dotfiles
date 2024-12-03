# /etc/bash.bashrc
[[ $- != *i* ]] && return

if [ -f ~/.bash/bash_profile ]; then
    . ~/.bash/bash_profile
fi

if [ -f ~/.bash/exports ]; then
	. ~/.bash/exports
fi

if [ -f ~/.bash/paths ]; then
	. ~/.bash/paths
fi

if [ -f ~/.bash/aliases ]; then
	. ~/.bash/aliases
fi

if [ -f ~/.bash/functions ]; then
	. ~/.bash/functions
fi

if [ -f ~/.bash/prompt ]; then
	. ~/.bash/prompt
fi

if [ -f ~/.bash/logout/.bash_logout ]; then
        . ~/.bash/logout/.bash_logout
fi

