#!/bin/bash

# Function to install a missing package
install_if_missing() {
    PACKAGE=$1
    if ! command -v $PACKAGE &> /dev/null
    then
        echo "$PACKAGE could not be found. Installing $PACKAGE..."
        sudo apt update && sudo apt install -y $PACKAGE
        if ! command -v $PACKAGE &> /dev/null
        then
            echo "Error: $PACKAGE could not be installed. Exiting."
            exit 1
        fi
    fi
}

# Check and install dependencies
install_if_missing "curl"
install_if_missing "jq"
install_if_missing "wget"
install_if_missing "unzip"
install_if_missing "fc-cache"  # Part of fontconfig
install_if_missing "fontconfig"  # Installing fontconfig to ensure fonts work

# Install Oh My Posh
echo "Installing Oh My Posh..."
if ! sudo wget -q https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh; then
    echo "Error: Failed to download Oh My Posh."
    exit 1
fi
sudo chmod +x /usr/local/bin/oh-my-posh

# Install fonts required for Oh My Posh themes
FONT_DIR="$HOME/.local/share/fonts"
FONT_ZIP="FiraCode.zip"

echo "Installing Nerd Fonts..."
if ! sudo wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip -O $FONT_ZIP; then
    echo "Error: Failed to download FiraCode Nerd Font."
    exit 1
fi

# Create the fonts directory if it doesn't exist
mkdir -p $FONT_DIR

# Unzip fonts into the font directory
if ! sudo unzip -o $FONT_ZIP -d $FONT_DIR; then
    echo "Error: Failed to extract FiraCode Nerd Fonts."
    exit 1
fi

# Clear the font cache
sudo fc-cache -fv || echo "Warning: Failed to refresh font cache."

# Remove the font zip file
rm -f $FONT_ZIP

# Fetch all available themes
THEMES_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/themes.json"
echo "Fetching available themes..."

# Download and parse the themes JSON
THEMES=$(curl -s $THEMES_URL | jq -r '.[].name')
if [ -z "$THEMES" ]; then
    echo "Error: Failed to fetch themes or no themes available."
    exit 1
fi

# List all themes
echo "Here are the available Oh My Posh themes:"
echo "$THEMES"

# Ask user to pick a theme
echo "Please select a theme from the list above:"
read -p "Enter theme name: " THEME_NAME

# Verify the selected theme
if ! echo "$THEMES" | grep -q "^$THEME_NAME$"; then
    echo "Error: Theme '$THEME_NAME' not found."
    exit 1
fi

# Create the configuration file for Oh My Posh
CONFIG_FILE="$HOME/.poshthemes/$THEME_NAME.json"
mkdir -p "$HOME/.poshthemes"

# Download the selected theme
echo "Downloading the selected theme..."
if ! curl -s https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$THEME_NAME.omp.json -o $CONFIG_FILE; then
    echo "Error: Failed to download the theme '$THEME_NAME'."
    exit 1
fi

# Detect the current shell
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

# Source the shell configuration to apply changes immediately (in the current session)
echo "Applying theme..."
source $CONFIG_PATH || echo "Warning: Could not apply theme immediately. It will take effect on next terminal session."

# Reboot system option
read -p "Do you want to reboot the system now? (y/n): " REBOOT_ANSWER
if [[ $REBOOT_ANSWER == "y" || $REBOOT_ANSWER == "Y" ]]; then
    echo "Rebooting the system..."
    sudo reboot
else
    echo "Reboot skipped. The theme will be applied when you restart the terminal."
fi
