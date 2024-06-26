################# DO NOT MODIFY THIS FILE #######################
####### PLACE YOUR CONFIGS IN ~/.config/szsh/zshrc FOLDER #######
#################################################################

# This file is created by szsh setup.
# Place all your .zshrc configurations / overrides in a single or multiple files under ~/.config/szsh/zshrc/ folder
# Your original .zshrc is backed up at ~/.zshrc-backup-%y-%m-%d


# Load szsh configurations
source "$HOME/.config/szsh/szshrc.zsh"

# Any zshrc configurations under the folder ~/.config/szsh/zshrc/ will override the default szsh configs.
# Place all of your personal configurations over there
ZSH_CONFIGS_DIR="$HOME/.config/szsh/zshrc"

if [ "$(ls -A $ZSH_CONFIGS_DIR)" ]; then
    for file in "$ZSH_CONFIGS_DIR"/* "$ZSH_CONFIGS_DIR"/.*; do
        # Exclude '.' and '..' from being sourced
        if [ -f "$file" ]; then
            source "$file"
        fi
    done
fi

# Now source oh-my-zsh.sh so that any plugins added in ~/.config/szsh/zshrc/* files also get loaded
source $ZSH_CUSTOM/oh-my-zsh.sh


# Configs that can only work after "source $ZSH/oh-my-zsh.sh", such as Aliases that depend oh-my-zsh plugins

# Now source fzf.zsh , otherwise Ctr+r is overwritten by ohmyzsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPS="--extended"

