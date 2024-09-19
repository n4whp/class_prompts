#!/bin/bash

# Define paths
BASHRC_PATH=~/.bashrc
BACKUP_PATH=~/.bashrc.bak

# Backup .bashrc if not already backed up
if [ ! -f "$BACKUP_PATH" ]; then
    cp "$BASHRC_PATH" "$BACKUP_PATH"
    echo "Backup of .bashrc saved as $BACKUP_PATH"
else
    echo "Backup already exists as $BACKUP_PATH"
fi

# Define the custom prompt
CUSTOM_PS1='\[\e[1;32m\]┌──(\[\e[1;31m\]\u\[\e[1;32m\]㉿\h)-[\[\e[1;34m\]\w\[\e[1;32m\]]\n└─\$ \[\e[m\]'

# Check if the custom prompt is already in .bashrc
if grep -q 'CUSTOM_PS1' "$BASHRC_PATH"; then
    echo "Custom prompt already set in .bashrc"
else
    # Append the changes to .bashrc
    {
        echo ""
        echo "# Save the original PS1 prompt"
        echo 'if [ -z "$ORIGINAL_PS1" ]; then'
        echo '    export ORIGINAL_PS1="$PS1"'
        echo 'fi'
        echo ""
        echo "# Custom prompt"
        echo "export PS1='$CUSTOM_PS1'"
        echo ""
        echo "# Function to revert to the original prompt"
        echo 'revert_prompt() {'
        echo '    export PS1="$ORIGINAL_PS1"'
        echo '}'
    } >> "$BASHRC_PATH"

    echo "Updated .bashrc with custom prompt and revert function."
fi

# Reload .bashrc to apply changes
source "$BASHRC_PATH"
echo "Reloaded .bashrc to apply changes."
