Smart Yass: ~~Yubikey~~ Smart Card-based password manager
===========

**Smart Yass is neither used nor endorsed by Yubico. I am neither employed nor affiliated with Yubico.**

Used correctly, Smart Yass requires each following to retrieve a password from a vault (without the necessary private key material ever being on the same computer as the vault):
1.  The Smart Yass vault's master passphrase (something you know),
2.  A smart card coupled to the computer (something you have),
3.  The user to physically interact with the smart card (something you do).

Smart Yass only provides meaningful security features to disciplined users that have followed the instructions and recommendations discussed herein. If you are not using a smart card, then there is little value in using Smart Yass over other password managers. If you are not using [strong passwords](https://ssd.eff.org/en/module/creating-strong-passwords), then – um – I hope you brought your knee pads because you are [getting fucked](https://haveibeenpwned.com/)!

## Relevant Security Advisories

**Security Advisory 2017-10-16**: Be sure that you are not in the class of people that fall into this sad category of [poorly implemented crypto on smart cards](https://www.yubico.com/support/security-advisories/ysa-2017-01/) (including some Yubikeys). Avoid this mess by generating your keys using standard implementations, like GnuPG. See this [great drduh tutorial](https://github.com/drduh/YubiKey-Guide).

## Dependencies

-   GnuPG 2 or later,
-   openssl,
-   jq,
-   tr,
-   public key,
-   corresponding private key material.

Please do not generate or store your private key material on the same computer as your vault. 

## Smart Cards

Smart Yass can work with any smart card that holds private key material, supports OpenSC, and has the features/functions discussed below, but I have only tested this with a Yubikey 4.

### Yubikey 4 (Recommended)

A Yubikey 4 that is loaded with three 4096-bit subkeys for encryption, signing and authentication. The subkeys should be generated from a master private key that has never been on the same computer as the Smart Yass vault, and preferably generated on an air-gapped computer. See this [great drduh tutorial](https://github.com/drduh/YubiKey-Guide) for instructions.

You should configure your Yubikey 4 with "touch for crypto operations", so that the Yubikey 4 will only perform a cryptographic operation in response to a touch. Although some Yubikey 4 features use a touch mechanism out of the box, this feature is ***not*** enabled out of the box. See Yubico's [tutorial](https://developers.yubico.com/PGP/Card_edit.html#_yubikey_4_touch) (scroll up a little after you select this link because the website UI sucks).

### Yubikey NEO

A Yubikey NEO is better than nothing, but if you must use a NEO, then you should be rigorous about removing your NEO from your computer immediately after you perform a crypto operation. Unlike Yubikey 4, Yubikey NEO does not have the "touch for crypto operations" feature. Accordingly, you should remove your Yubikey NEO when you are not using it for crypto operations or authentication.

Make sure that you have [upgraded your firmware](https://developers.yubico.com/ykneo-openpgp/SecurityAdvisory%202015-04-14.html). Otherwise, you should schedule a nice night out with Magic Johnson to rap about the good ole days, share some great wine, and reminisce about how you both found out that you probably shared more than you had intended with total strangers.

# Usage

## Initialize a vault

```bash
yass init --recipient USER-ID [--master-passphrase passphrase]
```

Creates a Smart Yass vault in a directory defined `YASSHOME`, which defaults to `$HOME/.yass`.

## Open and use vault

```bash
yass open
```

Open the vault in memory and waits to receive CRUD, list, and/or quit commands:

```markdown
# creates a container with the name, asks for clear and secure payloads
create container_name

# displays the clear payload, and copies the secure payload to the clipboard
read container_name

# update the container's clear or secure payload
update container_name clear|secure

# remove or delete the container
rm|delete container_name

# list container names
ls|list [regex]

# quit and remove open vault from memory
quit
```

## Destroy vault

```bash
yass destroy-my-motherfucking-yass-vault
```

Does what you think it does. Don't be a dumbass. I'm not even sure why you read this line.

# Smart Yass Vault Schema

A Smart Yass vault is a symmetrically encrypted JSON file that is signed with the creator's private key material.  The following describes the Smart Yass vault format.

```json
{
    "recipient": "PK USER-ID",
    "version": "0.0.1",
    "pk": "armored public key",
    "containers": {
        "containers": {
            "name": {
                "clear-payload": "Data that can be displayed in the clear, e.g., username.",
                "secure-payload": "PK encrypted payload, e.g., password"
            }
        }
    }
}
```

# License – MIT

Copyright © 2017 Tom Johnson

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
