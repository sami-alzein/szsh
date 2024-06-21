#!/bin/bash

### To Uninstall
#To uninstall simply delete ~/.zshrc and ~/.config/szsh/. The script creates a backup of your original .zshrc in the home folder with the filename indicating it's a backup. Rename it back to .zshrc

uninstall() {
    echo "Uninstalling szsh..."
    rm -rf ~/.config/szsh
    rm -rf ~/.zshrc
    echo "Uninstalled szsh"
}