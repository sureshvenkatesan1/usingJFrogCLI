#!/bin/bash

# Set default values for GPG key details (can be overridden by parameters)
KEYPAIR_NAME=${1:-"jfrog_rbv2_key1"}
ALIAS_NAME=${2:-"jfrog_distribution_key"}
COMMENT=${3:-"jfrog_distribution_key"}
EMAIL=${4:-"jfrog_distribution_key@yourdomain.com"}
KEY_LENGTH=${5:-4096}
EXPIRE_DATE=${6:-0}
GPG_HOMEDIR=${7:-"./gpg"}
JSON_FILE_PATH=${8:-"./thekey.json"}
# Define output filenames
PUBLIC_KEY_FILE="./gpg_public_key.asc"
PRIVATE_KEY_FILE="./gpg_private_key.asc"

# Create GPG homedir if it doesn't exist
mkdir -p "$GPG_HOMEDIR"

# Set permissions to avoid the GPG unsafe permissions warning
chmod 700 "$GPG_HOMEDIR"

# Ask if the key should be created with a passphrase
read -p "Do you want to create the GPG key with a passphrase? (y/n): " CREATE_PASSPHRASE
PASSPHRASE=""

if [ "$CREATE_PASSPHRASE" == "y" ]; then
  # Ask for the passphrase
  read -sp "Enter your passphrase: " PASSPHRASE
  echo ""
  read -sp "Confirm your passphrase: " PASSPHRASE_CONFIRM
  echo ""
  if [ "$PASSPHRASE" != "$PASSPHRASE_CONFIRM" ]; then
    echo "Passphrases do not match. Exiting."
    exit 1
  fi
fi

# List all keys matching the email
KEY_LIST=$(gpg --homedir "$GPG_HOMEDIR" --list-keys --with-colons "$EMAIL" | grep '^pub' | cut -d':' -f5)

if [ -n "$KEY_LIST" ]; then
  echo "Keys found for email $EMAIL:"
  gpg --homedir "$GPG_HOMEDIR" --list-keys "$EMAIL"
  
  # Prompt user to create a new key or delete an existing one
  echo "Do you want to create a new key, delete an existing key, or continue with existing keys?"
  echo "1) Create a new key"
  echo "2) Delete an existing key"
  echo "3) Continue with existing keys"
  read -p "Choose an option (1, 2, or 3): " ACTION
  
  if [ "$ACTION" == "1" ]; then
    # Continue to key creation below
    echo "Creating a new GPG key..."
  elif [ "$ACTION" == "2" ]; then
    echo "Available keys for deletion:"
    gpg --homedir "$GPG_HOMEDIR" --list-keys "$EMAIL"
    read -p "Enter the Key ID you want to delete: " DELETE_KEY_ID
    
    if [ -n "$DELETE_KEY_ID" ]; then
      # Verify the passphrase by attempting to unlock the private key
      if [ -n "$PASSPHRASE" ]; then
        echo "Verifying passphrase..."
        gpg --homedir "$GPG_HOMEDIR" --batch --pinentry-mode loopback --passphrase "$PASSPHRASE" --export-secret-keys "$DELETE_KEY_ID" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
          echo "Invalid passphrase. Cannot delete the key."
          exit 1
        fi
      fi
      
      # If passphrase is correct, delete the key
      if [ -n "$PASSPHRASE" ]; then
        echo "Deleting the key with passphrase."
        gpg --homedir "$GPG_HOMEDIR" --batch --yes --pinentry-mode loopback --passphrase "$PASSPHRASE" --delete-secret-keys "$DELETE_KEY_ID"
        gpg --homedir "$GPG_HOMEDIR" --batch --yes --pinentry-mode loopback --passphrase "$PASSPHRASE" --delete-keys "$DELETE_KEY_ID"
      else
        # No passphrase; delete key forcefully
        gpg --homedir "$GPG_HOMEDIR" --batch --yes --delete-secret-keys "$DELETE_KEY_ID"
        gpg --homedir "$GPG_HOMEDIR" --batch --yes --delete-keys "$DELETE_KEY_ID"
      fi
      echo "Key $DELETE_KEY_ID deleted."
    else
      echo "No valid Key ID entered."
      exit 1
    fi
    exit 0
  elif [ "$ACTION" == "3" ]; then
    echo "Continuing with existing keys."
  else
    echo "Invalid option. Exiting."
    exit 1
  fi
fi

# If the user chose to create a new key or no keys existed
if [ "$ACTION" == "1" ] || [ -z "$KEY_LIST" ]; then
  # Generate key details input for batch mode
  if [ -n "$PASSPHRASE" ]; then
    # If a passphrase is provided, include it in the key creation
    cat >keydetails <<EOF
      %echo Generating a GPG key
      Key-Type: RSA
      Key-Length: $KEY_LENGTH
      Subkey-Type: RSA
      Subkey-Length: $KEY_LENGTH
      Name-Real: $ALIAS_NAME
      Name-Comment: $COMMENT
      Name-Email: $EMAIL
      Expire-Date: $EXPIRE_DATE
      Passphrase: $PASSPHRASE
      %commit
      %echo done
EOF
  else
    # If no passphrase, use %no-ask-passphrase and %no-protection
    cat >keydetails <<EOF
      %echo Generating a GPG key
      Key-Type: RSA
      Key-Length: $KEY_LENGTH
      Subkey-Type: RSA
      Subkey-Length: $KEY_LENGTH
      Name-Real: $ALIAS_NAME
      Name-Comment: $COMMENT
      Name-Email: $EMAIL
      Expire-Date: $EXPIRE_DATE
      %no-ask-passphrase
      %no-protection
      %commit
      %echo done
EOF
  fi

  # Generate the GPG key
  gpg --homedir "$GPG_HOMEDIR" --batch --gen-key keydetails

  # List the new key(s)
  KEY_LIST=$(gpg --homedir "$GPG_HOMEDIR" --list-keys --with-colons "$EMAIL" | grep '^pub' | cut -d':' -f5)
fi

# After listing or creating the keys, prompt for export
KEY_COUNT=$(echo "$KEY_LIST" | wc -l)

if [ "$KEY_COUNT" -gt 1 ]; then
  echo "Multiple keys found for email $EMAIL:"
  gpg --homedir "$GPG_HOMEDIR" --list-keys "$EMAIL"
  
  # Prompt the user to select a key
  echo "Enter the Key ID of the key you want to export:"
  read -r KEY_ID
else
  # If only one key exists, automatically select it
  KEY_ID=$(echo "$KEY_LIST" | head -n 1)
fi

if [ -z "$KEY_ID" ]; then
  echo "Error: No key selected."
  exit 1
fi

# Export the private key (ASCII armored)
if [ -n "$PASSPHRASE" ]; then
  PRIV_KEY=$(gpg --armor --homedir "$GPG_HOMEDIR" --pinentry-mode loopback --passphrase "$PASSPHRASE" --export-secret-keys "$KEY_ID")
else
  PRIV_KEY=$(gpg --armor --homedir "$GPG_HOMEDIR" --export-secret-keys "$KEY_ID")
fi

if [ -z "$PRIV_KEY" ]; then
  echo "Error: Private key export failed."
  exit 1
fi

# Export the public key (ASCII armored)
PUB_KEY=$(gpg --armor --homedir "$GPG_HOMEDIR" --export "$KEY_ID")
if [ -z "$PUB_KEY" ]; then
  echo "Error: Public key export failed."
  exit 1
fi


# Save the keys to files (remove trailing newlines)
printf "%s" "$PRIV_KEY" > "$PRIVATE_KEY_FILE"
printf "%s" "$PUB_KEY" > "$PUBLIC_KEY_FILE"

# Process keys to replace newlines with \n
PRIV_KEY=$(printf "%s" "$PRIV_KEY" | awk '{printf "%s\\n", $0}'| sed 's/\\n$//')
PUB_KEY=$(printf "%s" "$PUB_KEY" | awk '{printf "%s\\n", $0}'| sed 's/\\n$//')

# Generate the JSON request body and save it to the specified JSON file
# https://jfrog.com/help/r/jfrog-rest-apis/create-key-pair
if [ -n "$PASSPHRASE" ]; then
  cat >"$JSON_FILE_PATH" <<EOF
{
  "pairName": "${KEYPAIR_NAME}",
  "pairType": "GPG",
  "alias": "${ALIAS_NAME}",
  "privateKey": "${PRIV_KEY}",
  "publicKey": "${PUB_KEY}",
  "passphrase": "${PASSPHRASE}"
}
EOF
else
  cat >"$JSON_FILE_PATH" <<EOF
{
  "pairName": "${KEYPAIR_NAME}",
  "pairType": "GPG",
  "alias": "${ALIAS_NAME}",
  "privateKey": "${PRIV_KEY}",
  "publicKey": "${PUB_KEY}",
  "passphrase": ""
}
EOF
fi

echo "GPG keys generated and saved to ${JSON_FILE_PATH} successfully."
