#!/bin/bash

# Define paths
BASHRC_PATH=~/.bashrc
BACKUP_PATH=~/.bashrc.bak

# Backup the existing .bashrc file if not already backed up
if [ ! -f "$BACKUP_PATH" ]; then
    cp "$BASHRC_PATH" "$BACKUP_PATH"
    echo "Backup of .bashrc saved as $BACKUP_PATH"
fi

# Overwrite .bashrc with new content
cat << 'EOF' > "$BASHRC_PATH"
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Setup custom prompt
CUSTOM_PS1='\[\e[1;32m\]┌──(\[\e[1;31m\]\u\[\e[1;32m\]㉿\h)-[\[\e[1;34m\]\w\[\e[1;32m\]]\n└─\$ \[\e[m\]'
export PS1="$CUSTOM_PS1"

# Save the original PS1 prompt
if [ -z "$ORIGINAL_PS1" ]; then
    export ORIGINAL_PS1="$PS1"
fi

# Function to revert to the original prompt
revert_prompt() {
    export PS1="$ORIGINAL_PS1"
}

# Set LS_COLORS for `ls`
# Blue directories, green executables
export LS_COLORS='di=34:ex=32'

# Enable color support for `ls`
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -la'
alias l='ls -CF'

# Enable Bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

EOF

# Reload .bashrc to apply changes
source "$BASHRC_PATH"
echo "Rewritten and reloaded .bashrc with custom configurations."
