
# RBV1 GPG Key Generation Script
[generate_gpg_key.sh](generate_gpg_key.sh) script automates the process of generating a GPG key pair (public and private keys) and creates a JSON file with the keys for integration with JFrog Distribution. It also provides options to manage existing keys associated with an email address.

## Features

- Generate a new GPG key pair (public/private).
- List existing GPG keys associated with an email address.
- Delete existing GPG keys (both public and secret) by Key ID.
- Export the public and private keys in a JSON format for use in JFrog Distribution.
- Allows you to specify the location where the JSON file is saved.

## Prerequisites

Ensure that you have the following tools installed:

- **GPG**: Version 2.x is recommended.
- **Bash**: The script is designed to run in a Unix-like environment (Linux/macOS).

## Usage

### 1. Make the Script Executable

To begin using the script, you must first make it executable. Run the following command:

```bash
chmod +x generate_gpg_key.sh
```

### 2. Running the Script

You can run the script with or without parameters. Below are examples of how to use the script.

#### Command Syntax

```bash
./generate_gpg_key.sh [ALIAS_NAME] [COMMENT] [EMAIL] [KEY_LENGTH] [EXPIRE_DATE] [GPG_HOMEDIR] [JSON_FILE_PATH]
```

### 3. Parameters

The script accepts the following parameters:

| Parameter      | Description                                                                                       | Default Value                         |
| -------------- | ------------------------------------------------------------------------------------------------- | ------------------------------------- |
| `ALIAS_NAME`    | The name associated with the GPG key.                                                              | `jfrog_distribution_key`              |
| `COMMENT`      | A comment to be added to the key.                                                                  | `jfrog_distribution_key`              |
| `EMAIL`        | The email associated with the GPG key.                                                             | `jfrog_distribution_key@yourdomain.com` |
| `KEY_LENGTH`   | Length of the RSA key. Recommended value: 2048 or 4096.                                             | `2048`                                |
| `EXPIRE_DATE`  | Expiry date of the GPG key. `0` means the key never expires.                                        | `0`                                   |
| `GPG_HOMEDIR`  | Directory where GPG stores key data.                                                               | `./gpg`                               |
| `JSON_FILE_PATH` | Full path where the generated JSON file containing the public and private keys will be saved.     | `./thekey.json`                       |

### 4. Example Usage

#### Generating a GPG Key

```bash
./generate_gpg_key.sh "Your Name" "Your Comment" "your-email@domain.com" 2048 0 "/path/to/gpg" "/path/to/output/thekey.json"
```

This command will:
- Generate a GPG key for "Your Name" with email "your-email@domain.com".
- The key length will be 2048 bits.
- The generated GPG keys will be saved in the directory `/path/to/gpg`.
- A JSON file containing the public and private keys will be saved to `/path/to/output/thekey.json`.

#### Listing Existing Keys and Deleting Keys

If there are existing keys associated with the specified email (`your-email@domain.com`), the script will:
1. List the existing keys.
2. Provide an option to either:
   - **Create a new key**.
   - **Delete an existing key**.
   - **Continue with the existing keys**.

If you choose to delete an existing key, the script will prompt you to select which key to delete by Key ID.

#### Exporting GPG Keys

After generating or choosing an existing key, the script will:
- Export the public and private keys in ASCII armored format.
- Generate a JSON request body in the following format:

```json
{
  "key": {
    "public_key": "-----BEGIN PGP PUBLIC KEY BLOCK-----\n...\n-----END PGP PUBLIC KEY BLOCK-----",
    "private_key": "-----BEGIN PGP PRIVATE KEY BLOCK-----\n...\n-----END PGP PRIVATE KEY BLOCK-----"
  },
  "propagate_to_edge_nodes": true,
  "fail_on_propagation_failure": false,
  "set_as_default": true
}
```

This JSON will be saved in the specified file (e.g., `/path/to/output/thekey.json`).

## Handling Multiple Keys

If multiple keys exist for the specified email, the script will list them and allow you to choose which key you want to export by Key ID.

## Deleting a Key Without Confirmation

When choosing to delete a key the script  forcefully deletes both the public and private keys without asking for confirmation, using the `--batch` and `--yes` flags.



## Troubleshooting

- **GPG Warnings**: If you see warnings related to unsafe permissions, ensure that the GPG home directory has the correct permissions:
  
  ```bash
  chmod 700 /path/to/gpg
  ```

