#!/bin/bash

# Backup the existing .bashrc
cp ~/.bashrc ~/.bashrc.bak

# Define the custom prompt
CUSTOM_PS1='\[\e[1;32m\]┌──(\[\e[1;31m\]\u\[\e[1;32m\]㉿\h)-[\[\e[1;34m\]\w\[\e[1;32m\]]\n└─\$ \[\e[m\]'

# Check if the .bashrc already contains the custom prompt
if grep -q 'CUSTOM_PS1' ~/.bashrc; then
    echo "Custom prompt already set in .bashrc"
    exit 1
fi

# Append the changes to .bashrc
cat <<EOF >> ~/.bashrc

# Save the original PS1 prompt
if [ -z "\$ORIGINAL_PS1" ]; then
    export ORIGINAL_PS1="\$PS1"
fi

# Custom prompt
export PS1='$CUSTOM_PS1'

# Optional: Function to revert to the original prompt
revert_prompt() {
    export PS1="\$ORIGINAL_PS1"
}
EOF

# Inform the user
echo "Updated .bashrc with custom prompt and revert function."
echo "Backup of the original .bashrc saved as .bashrc.bak"
