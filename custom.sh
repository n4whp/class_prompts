#!/bin/bash

# Function to check if a command exists and install it if not found
install_if_missing() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 could not be found. Installing $1..."
        sudo apt update && sudo apt install -y "$1"
    else
        echo "$1 is already installed."
    fi
}

# Check and install required dependencies
install_if_missing curl
install_if_missing jq
install_if_missing unzip

# Install Oh My Posh
echo "Installing Oh My Posh..."
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh

# Install Nerd Fonts for Oh My Posh themes
echo "Installing Nerd Fonts..."
sudo wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip -O FiraCode.zip
sudo unzip FiraCode.zip -d ~/.local/share/fonts
sudo fc-cache -fv
rm FiraCode.zip

# Fetch all available Oh My Posh themes
echo "Fetching available themes..."
THEMES_URL="https://ohmyposh.dev/docs/themes"
THEMES=$(curl -s https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/themes.json | jq -r '.[].name')

# List all themes
echo "Here are the available Oh My Posh themes:"
echo "$THEMES"

# Ask user to pick a theme
echo "Please select a theme from the list above:"
read -p "Enter theme name: " THEME_NAME

# Verify if the selected theme exists
if echo "$THEMES" | grep -q "^$THEME_NAME$"; then
    echo "Selected theme: $THEME_NAME"
else
    echo "Theme not found. Exiting."
    exit 1
fi

# Create the configuration file for Oh My Posh
CONFIG_FILE="$HOME/.poshthemes/$THEME_NAME.json"

# Download the selected theme
echo "Downloading the selected theme..."
mkdir -p ~/.poshthemes
curl -s https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$THEME_NAME.omp.json -o $CONFIG_FILE

# Set up Oh My Posh in the appropriate shell configuration
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

# Reboot system prompt
read -p "Do you want to reboot the system now? (y/n): " REBOOT_ANSWER
if [[ $REBOOT_ANSWER == "y" || $REBOOT_ANSWER == "Y" ]]; then
    echo "Rebooting the system..."
    sudo reboot
else
    echo "Reboot skipped. The theme will be applied when you restart the terminal."
fi
