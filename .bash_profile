if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec startx
fi

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

