#!/bin/bash

usage () {
    cat <<'USAGE'
$0 [import|export] [KEYRING_NAME]
USAGE
    exit 1
}

if [[ $# -lt 2 || ! "$1" =~ import|export ]]; then
    usage
    exit 1
fi

COMMAND="$1"
KEYRING_NAME="$2"

if [[ $COMMAND == "import" ]]; then
    gpg --import $KEYRING_NAME-secret-gpg.key
    gpg --import-ownertrust $KEYRING_NAME-ownertrust-gpg.txt
elif [[ $COMMAND == "export" ]]; then
    gpg --export $KEYRING_NAME > $KEYRING_NAME-public-gpg.key
    gpg --export-secret-keys $KEYRING_NAME > $KEYRING_NAME-secret-gpg.key
    gpg --export-ownertrust > $KEYRING_NAME-ownertrust-gpg.txt
fi
