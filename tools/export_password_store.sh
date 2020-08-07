#!/usr/bin/env bash

export PASSWORD_STORE_DIR="$HOME/.password-store"

shopt -s nullglob globstar
prefix=${PASSWORD_STORE_DIR:-$HOME/.password-store}

echo $prefix

for file in "$prefix"/**/*.gpg; do
    file="${file//$prefix\//}"
    printf "%s\n" "Name: ${file%.*}" >> exported_passes.txt
    pass "${file%.*}" >> exported_passes.txt
    printf "\n\n" >> exported_passes.txt
done
