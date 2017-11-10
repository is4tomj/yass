#!/usr/bin/env bash

### Copyright © 2017 Tom Johnson

set -euo pipefail # safety net for things going down, and delete x if not in debug


POSITIONAL=()
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
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

if [ -n "${POSITIONAL+x}" ] && [ ${#POSITIONAL[@]} -eq 1 ];
then
    set -- "${POSITIONAL[@]}" # restore positional parameters
    COMMAND=$1
else
    echo "Either no command given or bad arguments"
    exit 1
fi

case $COMMAND in
    init)
    if [ -n "${RECIPIENT+x}" ]; # only do the following if recipient is defined
    then
        if [ -z "${PASSPHRASE+x}" ]; # passphrase was not given in command line
        then
            yass-init.sh --recipient "$RECIPIENT"
        else
            yass-init.sh --recipient "$RECIPIENT" --master-passphrase "$PASSPHRASE"
        fi
    fi
    ;;
    open)
    yass-open.sh
    ;;
esac
