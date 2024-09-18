#!/bin/bash

# Step 1: Create the custom prompt script
echo 'export PS1="\[\e[32m\][\[\e[m\]\[\e[31m\]\u\[\e[m\]\[\e[33m\]@\[\e[m\]\[\e[32m\]\h\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[32m\]]\[\e[m\]\[\e[32;47m\]\\$\[\e[m\] "' > /tmp/custom_prompt.sh

# Step 2: Move the script to the /etc/profile.d directory (system-wide startup for login shells)
sudo mv /tmp/custom_prompt.sh /etc/profile.d/custom_prompt.sh

# Step 3: Make the script executable
sudo chmod +x /etc/profile.d/custom_prompt.sh

# Step 4: Confirm the script is installed
if [ -f /etc/profile.d/custom_prompt.sh ]; then
  echo "Custom prompt script has been successfully installed and will be sourced at boot."
else
  echo "Failed to install the custom prompt script."
fi
