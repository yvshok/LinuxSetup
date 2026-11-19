#!/bin/bash

# Read the active keyboard layout and display it in uppercase.
layout=$(setxkbmap -query | grep layout | awk '{print $2}')
echo "$layout" | tr '[:lower:]' '[:upper:]'
