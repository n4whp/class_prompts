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
install_if_missing "xmllint"

# Install fontconfig (which includes fc-cache)
echo "Installing fontconfig package (for fc-cache)..."
if ! sudo apt install -y fontconfig; then
    echo "Error: Failed to install fontconfig (which includes fc-cache)."
    exit 1
fi

# Ensure the ~/.local/share/fonts directory exists and is writable
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -d "$FONT_DIR" ]; then
    echo "Creating font directory at $FONT_DIR..."
    mkdir -p "$FONT_DIR"
fi

# Check if the directory is writable
if [ ! -w "$FONT_DIR" ]; then
    echo "Error: No write permission to $FONT_DIR."
    echo "Attempting to fix permissions..."
    
    sudo chown $USER:$USER "$FONT_DIR"
    sudo chmod u+rwx "$FONT_DIR"
    
    if [ ! -w "$FONT_DIR" ]; then
        echo "Error: Unable to gain write permission to $FONT_DIR. Exiting."
        exit 1
    fi
fi

# Clean up previous install if necessary
if [ -f "FiraCode.zip" ]; then
    echo "Removing old FiraCode.zip..."
    rm -f FiraCode.zip
fi

# Download and install FiraCode font
echo "Downloading FiraCode font..."
if ! wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip; then
    echo "Error: Failed to download FiraCode.zip. Exiting."
    exit 1
fi

# Unzip the font into the font directory
echo "Unzipping FiraCode.zip into $FONT_DIR..."
if ! unzip FiraCode.zip -d "$FONT_DIR"; then
    echo "Error: Failed to unzip FiraCode.zip. Exiting."
    exit 1
fi

# Remove the zip file after extraction
echo "Cleaning up..."
rm -f FiraCode.zip

# Refresh font cache
echo "Refreshing font cache with fc-cache..."
if ! fc-cache -fv; then
    echo "Error: Failed to refresh the font cache. Exiting."
    exit 1
fi

# Fetch available themes using Oh My Posh
echo "Fetching available Oh My Posh themes..."

API_RESPONSE=$(curl -s https://ohmyposh.dev/themes)

# Check if the response is HTML instead of JSON
if echo "$API_RESPONSE" | grep -q "<html>"; then
    echo "HTML detected in response. Attempting to parse for themes..."
    
    # Use xmllint to strip HTML and extract possible themes
    THEMES=$(echo "$API_RESPONSE" | xmllint --html --xpath "//a[contains(@href, '.omp.json')]/text()" - 2>/dev/null)
    
    if [ -z "$THEMES" ]; then
        echo "Error: Failed to parse HTML for themes. Exiting."
        echo "Dumping HTML response:"
        echo "$API_RESPONSE"
        exit 1
    fi
    
    echo "Extracted themes:"
    echo "$THEMES"
else
    # Try parsing the response as JSON if it's not HTML
    if ! echo "$API_RESPONSE" | jq empty; then
        echo "Error: The fetched response is not valid JSON. Dumping response:"
        echo "$API_RESPONSE"
        exit 1
    fi

    # If valid JSON, extract themes
    THEMES=$(echo "$API_RESPONSE" | jq -r '.[]')
    if [ -z "$THEMES" ]; then
        echo "Error: Could not retrieve themes. Exiting."
        exit 1
    fi

    echo "Here are the available Oh My Posh themes:"
    echo "$THEMES"
fi

# Prompt user to select a theme
read -p "Enter theme name: " theme_name

# Validate theme input
if [[ -z "$theme_name" || ! "$THEMES" =~ "$theme_name" ]]; then
    echo "Error: Invalid theme name. Exiting."
    exit 1
fi

echo "You have selected the $theme_name theme."

# Apply the selected theme (assuming Oh My Posh is already installed)
if ! oh-my-posh init bash --config ~/path/to/$theme_name.omp.json > ~/.bashrc; then
    echo "Error: Failed to apply the Oh My Posh theme. Exiting."
    exit 1
fi

echo "Theme applied successfully. Please restart your terminal or run 'source ~/.bashrc'."
