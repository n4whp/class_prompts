#!/bin/bash

# Function to check and install a package if not installed
install_if_missing() {
    package=$1
    if ! dpkg -l | grep -qw "$package"; then
        echo "Package $package is not installed. Installing it now..."
        sudo apt-get update
        sudo apt-get install -y "$package"
    else
        echo "$package is already installed."
    fi
}

# Function to handle "Oh My Posh" theme selection
choose_theme() {
    # List of known Oh My Posh themes
    known_themes=(
        "paradox"
        "starship"
        "atomic"
        "powerlevel10k_classic"
        "jandedobbeleer"
        "tonybaloney"
        "robbyrussell"
        "ys"
    )

    echo "Please choose a theme from the list below:"
    for i in "${!known_themes[@]}"; do
        echo "$((i + 1)). ${known_themes[$i]}"
    done

    read -p "Enter the number corresponding to the theme you want to use: " theme_choice

    if [[ $theme_choice -ge 1 && $theme_choice -le ${#known_themes[@]} ]]; then
        selected_theme="${known_themes[$((theme_choice - 1))]}"
        echo "You selected theme: $selected_theme"
        # Apply the theme
        oh-my-posh init bash --config "~/.poshthemes/$selected_theme.omp.json" | tee
    else
        echo "Invalid choice, please run the script again."
        exit 1
    fi
}

# Function to install Oh My Posh and download themes
install_oh_my_posh() {
    echo "Installing Oh My Posh..."

    # Install Oh My Posh
    sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
    sudo chmod +x /usr/local/bin/oh-my-posh

    # Make sure the themes directory exists
    mkdir -p ~/.poshthemes
    wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
    unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
    chmod u+rw ~/.poshthemes/*.json
    rm ~/.poshthemes/themes.zip

    echo "Oh My Posh installed successfully."
}

# Main function
main() {
    # Step 1: Install necessary packages
    install_if_missing "wget"
    install_if_missing "unzip"
    install_if_missing "jq"

    # Step 2: Install Oh My Posh if it's missing
    if ! command -v oh-my-posh &> /dev/null; then
        install_oh_my_posh
    else
        echo "Oh My Posh is already installed."
    fi

    # Step 3: Run the theme selection function
    choose_theme

    echo "Applying selected theme..."

    # Step 4: Additional operations if needed
    echo "Reloading terminal settings..."
    exec bash  # Reload the shell to apply changes

    echo "Setup completed!"
}

# Run the main function
main
