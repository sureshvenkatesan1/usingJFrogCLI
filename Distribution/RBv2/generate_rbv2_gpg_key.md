# GPG Key Generator for JFrog Distribution RBv2

[generate_rbv2_gpg_key.sh](generate_rbv2_gpg_key.sh) script generates GPG key pairs for use with JFrog Distribution Release Bundle v2. It creates both public and private keys and outputs them in a JSON format suitable for the JFrog Platform API.

## Features

- Generates RSA key pairs with configurable key length
- Optional passphrase protection for private keys
- Configurable key expiration
- JSON output compatible with JFrog Platform API
- Support for custom GPG home directory
- Interactive key management (create new/delete existing/use existing keys)

## Prerequisites

- GPG (GnuPG) installed on your system
- Bash shell environment
- Write permissions for the output directory

## Usage

```bash
./generate_rbv2_gpg_key.sh [REAL_NAME] [COMMENT] [EMAIL] [KEY_LENGTH] [EXPIRE_DATE] [GPG_HOMEDIR] [JSON_FILE_PATH] [PAIR_NAME]
```

### Parameters

1. `REAL_NAME` - Name/alias for the key (default: "jfrog_distribution_key")
2. `COMMENT` - Comment for the key (default: "jfrog_distribution_key")
3. `EMAIL` - Email address for the key (default: "jfrog_distribution_key@yourdomain.com")
4. `KEY_LENGTH` - RSA key length in bits (default: 4096)
5. `EXPIRE_DATE` - Key expiration in days, 0 for no expiration (default: 0)
6. `GPG_HOMEDIR` - Directory for GPG files (default: "./gpg")
7. `JSON_FILE_PATH` - Output JSON file path (default: "./thekey.json")
8. `PAIR_NAME` - Name for the key pair in JFrog Platform (default: "jfrog_rbv2_key1")

## Step-by-Step Guide

### 1. Create Working Directory

First, create a directory to store the generated keys:

```bash
mkdir -p /tmp/test/
```

### 2. Generate GPG Key Pair

Generate a new GPG key pair using the script:

```bash
bash Distribution/RBv2/generate_rbv2_gpg_key.sh \
    "jfrog_rbv2_key1" \
    "jfrog_distribution_rbv2_key1" \
    "jfrog_distribution_rbv2_key1" \
    "jfrog_distribution_rbv2_key1@jfrog.com" \
    4096 \
    0 \
    /tmp/gpg \
    /tmp/test/thekey1.json
```

## Output

The script generates a JSON file containing GPG 4096-bit key pair:
- Key pair name
- Key type (GPG)
- Alias
- Private key (ASCII armored, with newlines replaced by \n)
- Public key (ASCII armored, with newlines replaced by \n)
- Passphrase 
- Store GPG files in `/tmp/gpg`
- Save the key pair JSON in `/tmp/test/thekey1.json`
- Save the private key in ./gpg_private_key.asc and public key in ./gpg_public_key.asc files for convenience
- Set no expiration date (0)


Example JSON output format:
```json
{
  "pairName": "jfrog_rbv2_key1",
  "pairType": "GPG",
  "alias": "jfrog_distribution_rbv2_key1",
  "privateKey": "-----BEGIN PGP PRIVATE KEY BLOCK-----\n...\n-----END PGP PRIVATE KEY BLOCK-----",
  "publicKey": "-----BEGIN PGP PUBLIC KEY BLOCK-----\n...\n-----END PGP PUBLIC KEY BLOCK-----",
  "passphrase": "optional_passphrase or empty string"
}
```

### 3. Upload to JFrog Platform

After generating the key pair, you can upload it to JFrog Platform using the JFrog CLI:

```bash
jf rt curl -s -XPOST "/api/security/keypair" \
    -H 'Content-Type: application/json' \
    --data-binary @/tmp/test/thekey1.json

```

## Notes

- The generated JSON file contains both public and private keys in ASCII-armored format
- Keys are formatted with `\n` for newlines to ensure valid JSON
- The upload command uses the silent flag (`-s`) to reduce output verbosity
- Make sure to keep your access token secure and never commit it to version control



## Security Considerations

- The script automatically sets appropriate permissions (700) on the GPG home directory
- Passphrase protection is optional but recommended for production use
- Private keys are sensitive information - handle the output JSON file securely
- The script provides options to manage existing keys to prevent accidental key duplicates

## Error Handling

The script includes error handling for:
- Failed key generation
- Failed key export
- Invalid passphrases
- Missing directories
- Existing keys with the same email

