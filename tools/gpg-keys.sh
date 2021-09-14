#!/bin/bash

usage () {
    cat <<'USAGE'
$0 [import|export] [KEYRING_NAME] [SOURCE_DIRECTORY]
USAGE
    exit 1
}

if [[ $# -lt 3 || ! "$1" =~ import|export ]]; then
    usage
    exit 1
fi

COMMAND="$1"
KEYRING_NAME="$2"
SOURCE_DIRECTORY="$3"

if [[ $COMMAND == "import" ]]; then
    gpg --import            "$3/$KEYRING_NAME-secret-gpg.key"
    gpg --import-ownertrust "$3/$KEYRING_NAME-ownertrust-gpg.txt"
elif [[ $COMMAND == "export" ]]; then
    gpg --export $KEYRING_NAME             > "$3/$KEYRING_NAME-public-gpg.key"
    gpg --export-secret-keys $KEYRING_NAME > "$3/$KEYRING_NAME-secret-gpg.key"
    gpg --export-ownertrust                > "$3/$KEYRING_NAME-ownertrust-gpg.txt"
fi
