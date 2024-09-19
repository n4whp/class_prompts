#!/bin/bash

# Function to display a line of colors
display_colors() {
    echo -e "\nBasic Colors:"
    for color in {0..7}; do
        echo -e "\033[38;5;${color}mColor ${color}\033[0m"
    done

    echo -e "\nHigh Intensity Colors:"
    for color in {8..15}; do
        echo -e "\033[38;5;${color}mColor ${color}\033[0m"
    done

    echo -e "\n256-Color Palette:"
    for color in {16..231}; do
        echo -e "\033[48;5;${color}m ${color} \033[0m"
        if (( (color - 16) % 6 == 5 )); then
            echo
        fi
    done

    echo -e "\nText Attributes:"
    echo -e "\033[1mBold\033[0m"
    echo -e "\033[3mItalic\033[0m"
    echo -e "\033[4mUnderlined\033[0m"
    echo -e "\033[7mInverse\033[0m"
    echo -e "\033[8mHidden\033[0m"

    echo -e "\nBackground Colors:"
    for color in {0..7}; do
        echo -e "\033[48;5;${color}m \033[0m"
    done

    echo -e "\nHigh Intensity Background Colors:"
    for color in {8..15}; do
        echo -e "\033[48;5;${color}m \033[0m"
    done
}

# Clear the terminal screen
clear

# Display the colors and attributes
display_colors

# Reset terminal to default settings
echo -e "\n\033[0m"
