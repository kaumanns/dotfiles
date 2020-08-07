#!/bin/bash

MYMAIL_SEARCHTERM="from:david@cis.lmu.de OR kaumanns@cis.lmu.de OR from:david@heidenblog.de"

MYMAIL_COUNT_BEFORE=`notmuch count $MYMAIL_SEARCHTERM`

NOTMUCH_OUTPUT=`notmuch new`

MYMAIL_COUNT_AFTER=`notmuch count $MYMAIL_SEARCHTERM`

if [[ "`uname`" == "Darwin" ]]; then
    # [[ 1 -le $(echo "`notmuch new`" | grep -c 'No new mail.') ]] \
        [[ $MYMAIL_COUNT_AFTER -ne $MYMAIL_COUNT_BEFORE ]] \
        || [[ "$NOTMUCH_OUTPUT" == *"No new mail"* ]] \
        || /usr/local/opt/terminal-notifier/terminal-notifier.app/Contents/MacOS/terminal-notifier \
            -title 'New mail' \
            -message 'New mail' \
            -group 'Mail' \
            -remove 'Mail'
fi
