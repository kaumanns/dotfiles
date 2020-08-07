#!/bin/bash

width=$(stty  size | awk 'BEGIN {FS = " "} {print $2;}')

asciiart --color --width $((width-5)) $1
