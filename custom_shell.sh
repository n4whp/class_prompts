#!/bin/bash

# Cleaning up font cache
echo "Cleaning up..."
fc-cache -r

# Refreshing font cache
echo "Refreshing font cache with fc-cache..."
fc-cache

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

# Main function
main() {
    # Check if oh-my-posh is installed
    if ! command -v oh-my-posh &> /dev/null; then
        echo "Oh My Posh is not installed. Installing now..."
        sudo apt install oh-my-posh
    fi

    # Run the choose_theme function
    choose_theme

    echo "Applying selected theme..."

    # More operations like reloading terminal, fonts, or anything else you have
    echo "Reloading terminal settings..."

    # Call other parts of your script here if needed
    # For example:
    # ./some_other_part_of_the_script.sh

    echo "Setup completed!"
}

# Run the main function
main
