#!/bin/bash

#
# Wrapper for StevenBlack's updateHostsFile.py, combining:
#
# 1. StevenBlack hosts file
# 2. List of host file URLs
# 3. Custom hosts file
#

set -e # Die on error

LIST_HOME="$HOME/git/dotfiles/home/hosts/.config/hosts"

HOSTS_REPO="$LIST_HOME/hosts"
HOSTS_URLS="$LIST_HOME/hosts-blacklist-urls"
HOSTS_BLACKLIST="$LIST_HOME/hosts-blacklist"
HOSTS_WHITELIST="$LIST_HOME/hosts-whitelist"

HOSTS_CUSTOM="/tmp/hosts_custom"

custom_hosts_from_urls () {
  cat "$HOSTS_URLS" \
    | grep -vE '^\s*#' \
    | grep -vE '^\s*$' \
    | sort \
    | uniq \
    | wget \
      --quiet \
      --input-file='-' \
      --output-document='-'
}

custom_hosts_from_blacklist () {
  cat $HOSTS_BLACKLIST
}

custom_hosts () {
  echo -e "$(custom_hosts_from_urls)\n$(custom_hosts_from_blacklist)" \
    | grep -vE '^\s*#' \
    | sed -E 's/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\s+//' \
    | grep -vE '^\s*$' \
    | sort \
    | uniq \
    | awk '{print "0.0.0.0 " $0}'
}

run () {
  echo "$(custom_hosts)" > "$HOSTS_CUSTOM"
  cd "$HOSTS_REPO" \
    && python3 updateHostsFile.py \
      --auto \
      --replace \
      --flush-dns-cache \
      --blacklist "$HOSTS_CUSTOM" \
      --whitelist "$HOSTS_WHITELIST"
}
      # --extensions social \

run
