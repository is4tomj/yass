#!/usr/bin/env bash

### Copyright © 2017 Tom Johnson

# safety net for things going down, and delete x if not in debug
set -euo pipefail

# Must be executed before any GPG crypto operations using a
# Smart Card configured to use touch. If not, pinentry may not be displayed.
export GPG_TTY=`tty`

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -r|--recipient)
    RECIPIENT="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--master-passphrase)
    PASSPHRASE="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    echo "Bad argument: $key"
    exit 1
    ;;
esac
done

if [ -z ${RECIPIENT+X} ];
then
    echo "No recipient identified. Please use --recipient USER-ID"
    exit 1
else
    echo "Recipient is $RECIPIENT"
fi


if [ -z ${PASSPHRASE+X} ];
then
    read -sp "Enter master passphrase: " pass1
    echo
    read -sp "Re-enter master passphrase: " pass2
    echo
    if [ "$pass1" == "$pass2" ];
    then
        PASSPHRASE=$pass1
    else
        echo "Passphrases did not match."
    fi
fi


######################
# Create JSON file
######################
VERSION="0.0.1"
RAWHKEY=$(openssl rand -base64 256)

PK=$(gpg --armor --export "$RECIPIENT")
HKEY=$(echo -n "$RAWHKEY" | gpg --encrypt --armor --recipient "$RECIPIENT" 2> /dev/null) 


JSON=$(jq -n -f vault-template.json --arg v "$VERSION" --arg r "$RECIPIENT" --arg pk "$PK" --arg key "$HKEY")

######################
# Create vault
######################

YASSHOME=${YASSHOME:-"$HOME/.yass"}
YASSVAULT="$YASSHOME/vault.gpg"

echo -n "$JSON" | gpg --encrypt --symmetric --sign --recipient "$RECIPIENT" --batch --yes --passphrase "$PASSPHRASE" --output "$YASSVAULT" #2> /dev/null
