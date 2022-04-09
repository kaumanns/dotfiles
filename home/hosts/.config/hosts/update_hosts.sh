#!/bin/bash

#
# Wrapper for StevenBlack's updateHostsFile.py, combining:
#
# 1. StevenBlack hosts file
# 2. List of host file URLs
# 3. Custom hosts file
#

set -e # Die on error

print_help () {
  echo "Usage: ./$0 -l <path to dir of hosts lists, repo, etc.>"
}

if [ "$#" -eq 0 ]
then
  print_help >&2
  exit 1
else
  while getopts "h:l:" opt
  do
    case "${opt}" in
      h )
        print_help >&2
        exit 1
        ;;
      l )
        list_home="$OPTARG"
        ;;
      ? )
        echo "$0: Invalid option: -$OPTARG" >&2
        exit 1
        ;;
      : )
        echo "$0: Option -$OPTARG needs path as an argument." >&2
        exit 1
        ;;
      * )
        print_help >&2
        exit 1
        ;;
    esac
  done
fi

HOSTS_REPO="$list_home/hosts"
HOSTS_URLS="$list_home/hosts-blacklist-urls"
HOSTS_BLACKLIST="$list_home/hosts-blacklist"
HOSTS_WHITELIST="$list_home/hosts-whitelist"

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

