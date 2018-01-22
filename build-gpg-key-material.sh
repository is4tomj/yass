#!/usr/bin/env bash

### Copyright © 2018 Tom Johnson

set -euo pipefail
#set -euxo pipefail # to debug, uncomment this line, and comment out above line


######################
# Do some configuration and version checking
######################

KERNELNAME=$(uname -a)

if [[ $KERNELNAME =~ ^Darwin ]];
then
    GPG=gpg

    # Darwin needs this, otherwise tr cannot parse /dev/urandom.
    export LC_ALL=C
else
    GPG=gpg2
fi

if [[ -n $(hash $GPG) ]];
then
    echo "Missing or cannot detect ${GPG}"
    exit 1
fi

REQVERSION='2.2.1'
GPGVERSION=$($GPG --version | grep -o -P 'gpg.*\d+\.\d+\.\d+' | grep -o -P '2\.2\.[1-9]')
echo "Version ${GPGVERSION}"
if [[ -n ${GPGVERSION} ]];
then
    echo "Using $GPG version ${GPGVERSION}."
else
    echo "$GPG version ${GPGVERSION} is installed, but need at least version ${REQVERSION}"
    exit 1
fi

######################
# Helpers
######################

# Generate random password of length n
# usage $(rpass n)
rpass() {
    tr -dc 'A-Za-z0-9_!@#$%^&*()\-+=' < /dev/urandom | head -c $1
}

############################
# Init directory and supporting documents
############################

# Create and change to tmp folder
export GNUPGHOME=$(mktemp -d) ; echo "Created new tmp directory: ${GNUPGHOME}"
cd $GNUPGHOME

# Create gpg.conf for key gen
cat << EOF > $GNUPGHOME/gpg.conf
use-agent
personal-cipher-preferences AES256 AES192 AES CAST5
personal-digest-preferences SHA512 SHA384 SHA256 SHA224
default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
cert-digest-algo SHA512
s2k-digest-algo SHA512
s2k-cipher-algo AES256
charset utf-8
fixed-list-mode
no-comments
no-emit-version
keyid-format 0xlong
list-options show-uid-validity
verify-options show-uid-validity
with-fingerprint
EOF

# Get recipient/user for keys
read -p "Recipient name: " NAME
read -p "Recipient Email: " EMAIL
echo

# Generate symmetric key to protect private key
export PASSPHRASE=$(rpass 64)

# Create parameter file for generating primary key-pair
GPGKEYGENPARAMS=$GNUPGHOME/gpg-key-gen.params
cat << EOF > $GPGKEYGENPARAMS
%echo Generating RSA 4096 key-pair
Key-Type: RSA
Key-Length: 4096

# Passphrase
%echo Passphrase is ${PASSPHRASE}
Passphrase: ${PASSPHRASE}

# Key identifying data
Name-Real: ${NAME}
Name-Email: ${EMAIL}

# No expiration if 0
Expire-Date: 0

# Do a commit here, so that we can later print "done" :-)
%commit
# %dry-run
%echo done
EOF


############################
# Run GPG commands
############################

# Build primary key-pair
$GPG --batch --full-generate-key $GPGKEYGENPARAMS

# Print public key fingerprint
$GPG --list-secret-keys "${EMAIL}"

# Get public key fingerprint from user
read -p "Copy/paste key fingerprint here: " FPR
echo

# Copy passphrase into clipboard for use to create subkeys and export keys
if [[ $KERNELNAME =~ ^Darwin ]];
then
    echo $PASSPHRASE | pbcopy
else
    echo $PASSPHRASE | xclip -i -r # primary (middle click) buffer
    echo $PASSPHRASE | xclip -selection c -r # clipboard
fi
echo "Copied passphrase into clipboard for the next commands."
echo

# Build subkeys
echo "Building rsa4096 sign subkey."
$GPG --quick-add-key "${FPR}" rsa4096 sign
echo

echo "Building rsa4096 auth subkey."
$GPG --quick-add-key "${FPR}" rsa4096 auth
echo

echo "Building rsa4096 encr subkey."
$GPG --quick-add-key "${FPR}" rsa4096 encr
echo

# Export keys
ARMOREDPUBLICKEY=$GNUPGHOME/${EMAIL}-armored-pubkey.txt
ARMOREDPRIVATEKEY=$GNUPGHOME/${EMAIL}-armored-privkey.txt
ARMOREDSUBKEYS=$GNUPGHOME/${EMAIL}-armored-subkeys.txt
PASSPHRASEFILE=$GNUPGHOME/${EMAIL}-passphrase.txt
echo "Exporting public key."
$GPG --armor --export $EMAIL > $ARMOREDPUBLICKEY
echo
echo "Exporting (symmetrically encrypted) secret key."
$GPG --armor --export-secret-keys $EMAIL > $ARMOREDPRIVATEKEY
echo
echo "Exporting subkeys."
$GPG --armor --export-secret-subkeys $EMAIL > $ARMOREDSUBKEYS
echo
echo "Exporting passphrase."
echo $PASSPHRASE > $PASSPHRASEFILE
echo

# Summary
echo
echo "Good news:"
echo "  -Created primary key-pair and subkeys for ${EMAIL}."
echo "  -Exported public key to ${ARMOREDPUBLICKEY}."
echo "  -Exported private key to ${ARMOREDPRIVATEKEY}."
echo "  -Exported subkeys to ${ARMOREDSUBKEYS}."
echo "  -Saved passphrase for private key in ${PASSPHRASEFILE}."
echo
echo "TODO:"
echo "  -If needed, create encrypted backup of ${GNUPGHOME} (passphrase, key-pair, subkeys, etc)."
echo '  -Insert Harware Token ("HT").'
echo '  -Configure HT and add subkeys using "${GPG} --card-edit".'
echo "  -Secure delete all key material and remaining byproducts at ${GNUPGHOME}."
echo '  -If needed, delete master private key using "${GPG} --delete-secret-key ${EMAIL}"'
