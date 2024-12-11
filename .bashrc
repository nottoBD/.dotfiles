[[ $- != *i* ]] && return

if [ -f ~/.bash/prompt ]; then
	. ~/.bash/prompt
fi

if [ -f ~/.bash/aliases ]; then
	. ~/.bash/aliases
fi

if [ -f ~/.bash/functions ]; then
	. ~/.bash/functions
fi

if [ -f ~/.bash/exports ]; then
	. ~/.bash/exports
fi

if [ -f ~/.bash/paths ]; then
	. ~/.bash/paths
fi
