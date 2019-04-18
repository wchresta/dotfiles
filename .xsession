#!/usr/bin/env bash

if [ $DESKTOP_SESSION = "none+xmonad" ]; then
  xss-lock -- i3lock-pixeled &
  xset dpms $((10*60)) $((20*60)) $((60*60)) &
  xset s $((20*60)) &
  
  # set key repetition speed
  xset r rate 330 50

  #xfce4-power-manager & 
  xfce4-volumed-pulse &

  polybar xmonad &

  kitty &

  #feh --bg-scale .background &
  # nixos uses .background-image for this

  # start kwallet and owncloud

  # Warn Java application that xmonad is not reparenting
  export _JAVA_AWT_WM_NONREPARENTING=1 

  disable-screensaver.sh
fi
