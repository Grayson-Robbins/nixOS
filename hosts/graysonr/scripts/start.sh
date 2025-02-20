#!/usr/bin/env bash

# initializing wallpaper daemon
swww init &

swww img ~/Pictures/Nature_Wallpaper.jpg & # Setting wallpaper

nm-applet --indicator & # Network Manager applet

waybar & # Launch waybar

#clipse -listen # Launch Clipse clipboard manager

copyq --start-server # Launch copyq clipboard manager

mako
