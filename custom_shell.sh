#!/bin/bash

# Backup the existing .bashrc if not already backed up
if [ ! -f ~/.bashrc.bak ]; then
    cp ~/.bashrc ~/.bashrc.bak
    echo "Backup of .bashrc saved as .bashrc.bak"
else
    echo "Backup already exists as .bashrc.bak"
fi

# Define the custom prompt
CUSTOM_PS1='\[\e[1;32m\]┌──(\[\e[1;31m\]\u\[\e[1;32m\]㉿\h)-[\[\e[1;34m\]\w\[\e[1;32m\]]\n└─\$ \[\e[m\]'

# Check if the .bashrc already contains the custom prompt
if grep -q 'CUSTOM_PS1' ~/.bashrc; then
    echo "Custom prompt already set in .bashrc"
    exit 1
fi

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
    echo "# Optional: Function to revert to the original prompt"
    echo 'revert_prompt() {'
    echo '    export PS1="$ORIGINAL_PS1"'
    echo '}'
} >> ~/.bashrc

# Inform the user
echo "Updated .bashrc with custom prompt and revert function."

# Reload .bashrc to apply changes
source ~/.bashrc
echo "Reloaded .bashrc to apply changes."
