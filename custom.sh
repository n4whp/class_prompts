#!/bin/bash

# Check if curl is installed
if ! command -v curl &> /dev/null
then
    echo "curl could not be found. Installing curl..."
    sudo apt update && sudo apt install -y curl
fi

# Check if jq is installed (for parsing JSON)
if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Installing jq..."
    sudo apt update && sudo apt install -y jq
fi

# Install Oh My Posh
echo "Installing Oh My Posh..."
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh

# Install fonts required for Oh My Posh themes
echo "Installing Nerd Fonts..."
sudo wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip -O FiraCode.zip
sudo unzip FiraCode.zip -d ~/.local/share/fonts
sudo fc-cache -fv
rm FiraCode.zip

# Fetch all available themes
THEMES_URL="https://ohmyposh.dev/docs/themes"
echo "Fetching available themes..."
THEMES=$(curl -s https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/themes.json | jq -r '.[].name')

# List all themes
echo "Here are the available Oh My Posh themes:"
echo "$THEMES"

# Ask user to pick a theme
echo "Please select a theme from the list above:"
read -p "Enter theme name: " THEME_NAME

# Verify theme name
if echo "$THEMES" | grep -q "^$THEME_NAME$"; then
    echo "Selected theme: $THEME_NAME"
else
    echo "Theme not found. Exiting."
    exit 1
fi

# Create the configuration file for Oh My Posh
CONFIG_FILE="$HOME/.poshthemes/$THEME_NAME.json"

# Download selected theme
echo "Downloading the selected theme..."
mkdir -p ~/.poshthemes
curl -s https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$THEME_NAME.omp.json -o $CONFIG_FILE

# Set up Oh My Posh in the shell configuration (bash or zsh)
echo "Configuring Oh My Posh with the selected theme..."

# Detect shell and apply the theme accordingly
if [[ $SHELL == *"bash"* ]]; then
    CONFIG_PATH="$HOME/.bashrc"
    echo "Detected bash shell."
    echo -e "\neval \"\$(oh-my-posh init bash --config $CONFIG_FILE)\"" >> $CONFIG_PATH
elif [[ $SHELL == *"zsh"* ]]; then
    CONFIG_PATH="$HOME/.zshrc"
    echo "Detected zsh shell."
    echo -e "\neval \"\$(oh-my-posh init zsh --config $CONFIG_FILE)\"" >> $CONFIG_PATH
else
    echo "Unsupported shell. Please use bash or zsh."
    exit 1
fi

# Source the shell configuration to apply changes immediately
echo "Applying theme..."
source $CONFIG_PATH

# Reboot system
read -p "Do you want to reboot the system now? (y/n): " REBOOT_ANSWER
if [[ $REBOOT_ANSWER == "y" || $REBOOT_ANSWER == "Y" ]]; then
    echo "Rebooting the system..."
    sudo reboot
else
    echo "Reboot skipped. The theme will be applied when you restart the terminal."
fi
