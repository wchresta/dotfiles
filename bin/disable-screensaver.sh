#!/usr/bin/env bash

# deactivate screensaver
THREE_HOURS=$((3*60*60))
xset s off
xset dpms $THREE_HOURS $THREE_HOURS $THREE_HOURS
