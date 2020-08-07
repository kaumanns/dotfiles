#!/bin/bash

language="${1-de}"
[[ "$language" == "de" ]] && curl -s http://sprichwortrekombinator.de/ | pup -p '.spwort text{}'
[[ "$language" == "en" ]] && curl -s http://proverb.gener.at/or/       | pup -p '.spwort text{}'

echo -e "\n"
