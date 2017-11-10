#!/usr/bin/env bash

### Copyright © 2017 Tom Johnson

set -euo pipefail # safety net for things going down, and delete x if not in debug

underline=`tput smul`
nounderline=`tput rmul`
bold=`tput bold`
normal=`tput sgr0`

YASSHOME=${YASSHOME:-"$HOME/.yass"}
YASSVAULT="$YASSHOME/vault.gpg"

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -v|--vault)
    YASSVAULT="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    echo "Bad argument: $key"
    exit 1
    ;;
esac
done


read -sp "Enter master passphrase: " PASSPHRASE
echo ""

######################
# Open vault
######################

VAULT=$(gpg --passphrase "$PASSPHRASE" --decrypt "$YASSVAULT")
RECIPIENT=$(echo "$VAULT" | jq '. ["recipient"]')


######################
# Usage vault
######################

usage() {
    echo "
${bold}Commands:${normal}

    create ${underline}container name${nounderline}
        Create a container with the name. Name must be unique; otherwise, this will fail.

    read|show ${underline}container name${nounderline} [clear|secure]
        Display the clear payload and/or copy the secure payload to the clipboard.
    
    update ${underline}container name${nounderline} ${underline}clear${nounderline}|${underline}secure${nounderline}
        Update container name, clear payload, or secure payload.

    rm|delete ${underline}container name${nounderline}
        Delete the named container.

    ls|list [regex filter]
        Display list of container names.

    quit
        Quite and remove vault from memory.
"
}


######################
# Take commands
######################

while [ true ]; do
    read -p " > " COMMAND
    COMMAND=$(echo -n "$COMMAND" | tr '[:lower:]' '[:upper:]') # make all commands uppercase

    case $COMMAND in
        CREATE)
        ;;
        READ|SHOW)
        ;;
        UPDATE)
        ;;
        RM|DELETE)
        ;;
        LS|LIST)
        ;;
        HELP)
        usage
        ;;
        EXIT|QUIT|CLOSE)
        exit 0
        ;;
        *)
        echo "I don't know wtf you're asking for."
        ;;
    esac
done
