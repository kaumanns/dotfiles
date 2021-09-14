#!/bin/bash

#
# Find mails in Maildir format by 'From:' pattern and mark them as seen.
#

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <mailbox> <pipe-separated names for the 'From: <NAME>' regex" >&2
  echo "E.g.: $0 ./Maildir 'peter|pan'" >&2
  exit 1
fi

ME="$2"
BOX="$1"
TARGET=cur
SOURCE=new

UNSEEN=$(find ${BOX}/${SOURCE}/ -type f)

# This condition avoids not-found errors in the subsequent for loop.
if [[ -n "$UNSEEN" ]]; then
  for m in $UNSEEN; do
    if [[ -n $(egrep -i "From:\s+[\"']?(${ME})" $m) ]]; then
      # Ensure suffix for flag indicator
      m=${m%:2,}:2,;

      # Change SOURCE to TARGET parent dir
      n=${BOX}/${TARGET}/${m##*/${SOURCE}/}S;

      mv $m $n;
    fi;
  done;
fi;

