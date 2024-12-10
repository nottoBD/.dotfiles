#!/bin/sh

[ -f ~/.xprofile ] && . ~/.xprofile

sysresources="/home/devid/.xresources"
sysmodmap="/home/devid/.xmodmap"

[ -f "$sysresources" ] && xrdb -merge "$sysresources"
[ -f "$sysmodmap" ] && xmodmap "$sysmodmap"

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

if [ -x "$(command -v xmonad)" ]; then
   exec /home/devid/.config/xmonad/xmonad-x86_64-linux
fi

