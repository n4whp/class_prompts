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

# Save the original PS1 prompt
if [ -z "$ORIGINAL_PS1" ]; then
    export ORIGINAL_PS1="$PS1"
fi

# Define colors
BLACK='\[\033[0;30m\]'
RED='\[\033[0;31m\]'
GREEN='\[\033[0;32m\]'
YELLOW='\[\033[0;33m\]'
BLUE='\[\033[0;34m\]'
MAGENTA='\[\033[0;35m\]'
CYAN='\[\033[0;36m\]'
WHITE='\[\033[0;37m\]'
RESET='\[\033[0m\]'

# Function to update prompt dynamically
update_prompt() {
    local last_command_status=$?
    if [ $last_command_status -eq 0 ]; then
        # If command was successful, use green
        PS1="${GREEN}┌──(${RED}\u${GREEN}㉿\h)-[${BLUE}\w${GREEN}]\n└─\$ ${RESET}"
    else
        # If command failed, use red
        PS1="${RED}┌──(${RED}\u${RED}㉿\h)-[${BLUE}\w${RED}]\n└─\$ ${RESET}"
    fi
}

# Set the custom prompt
export PROMPT_COMMAND=update_prompt

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
