#!/bin/bash


cp_hist_flag=false
noninteractive_flag=true
zsh_codex_flag=false


OH_MY_ZSH_FOLDER="$HOME/.config/czsh/oh-my-zsh"
OHMYZSH_CUSTOM_PLUGIN_PATH="$OH_MY_ZSH_FOLDER/custom/plugins"
OHMYZSH_CUSTOM_THEME_PATH="$OH_MY_ZSH_FOLDER/custom/themes"

#############################################################################################
######################################### VARIABLES #########################################
#############################################################################################


OH_MY_ZSHR_REPO="https://github.com/ohmyzsh/ohmyzsh.git"
AUTOSUGGESTIONS_PLUGIN_REPO="https://github.com/zsh-users/zsh-autosuggestions.git"
ZHS_CODEX_PLUGIN_REPO="https://github.com/tom-doerr/zsh_codex.git"
ZSH_SYNTAX_HIGHLIGHTING_REPO="https://github.com/zsh-users/zsh-syntax-highlighting.git"
ZSH_COMPLETIONS_REPO="https://github.com/zsh-users/zsh-completions.git"
ZSH_HISTORY_SUBSTRING_SEARCH_REPO="https://github.com/zsh-users/zsh-history-substring-search.git"
POWERLEVEL10K_REPO="https://github.com/romkatv/powerlevel10k.git"



################################################################################################
####################################### PROGRAMS REPOS #########################################
################################################################################################


FZF_REPO="https://github.com/junegunn/fzf.git"
FZF_TAB_REPO="https://github.com/Aloxaf/fzf-tab.git"
LAZYDOCKER_REPO="https://github.com/jesseduffield/lazydocker.git"
MARKER_REPO="https://github.com/jotyGill/marker.git"

################################################################################################
####################################### PLUGIN PATHS ###########################################
################################################################################################

FZF_TAB_PLUGIN_PATH="$OHMYZSH_CUSTOM_PLUGIN_PATH/fzf-tab"
ZSH_SYNTAX_HIGHLIGHTING_PATH="$OHMYZSH_CUSTOM_PLUGIN_PATH/zsh-syntax-highlighting"
ZSH_AUTOSUGGESTION_PATH="$OHMYZSH_CUSTOM_PLUGIN_PATH/zsh-autosuggestions"
ZSH_CODEX_PLUGIN_PATH="$OHMYZSH_CUSTOM_PLUGIN_PATH/zsh_codex"
ZSH_COMPLETION_PLUGIN_PATH="$OHMYZSH_CUSTOM_PLUGIN_PATH/zsh-completions"
ZSH_HISTORY_SUBSTRING_PLUGIN_PATH=$OHMYZSH_CUSTOM_PLUGIN_PATH/zsh-history-substring-search

POWERLEVEL_10K_PATH=$OHMYZSH_CUSTOM_THEME_PATH/powerlevel10k

################################################################################################
####################################### INSTALLATION PATHS #####################################
################################################################################################
FZF_INSTALLATION_PATH=$HOME/.config/czsh/fzf    
LAZYDOCKER_INSTALLATION_PATH=$HOME/.config/czsh/lazydocker
MARKER_PATH=$HOME/.config/czsh/marker


# Loop through all arguments
for arg in "$@"; do
    case $arg in
    --cp-hist | -c)
        cp_hist_flag=true
        ;;
    --interactive | -n)
        noninteractive_flag=false
        ;;
    --codex | -x)
        zsh_codex_flag=true
        ;;
    *)
        # Handle any other arguments or provide an error message
        ;;
    esac
done



#############################################################################################
####################################### Utilities ###########################################
#############################################################################################

echoIULRed() {
    echo -e "\\033[3;4;31m$*\\033[m"
}

logWarning() {
    echo -e "\\033[33m$*\\033[m"
}

logInfo() {
    echo -e "\\033[32m$*\\033[m"
}

logError() {
    echo -e "\\033[31m$*\\033[m"
}

logProgress() {
    echo -e "\\033[36m$*\\033[m"
}

#############################################################################################
####################################### FUNCTIONS #########################################
#############################################################################################

prerequists=("zsh" "git" "wget" "bat" "curl" "python3-pip" "fontconfig")
missing_packages=()

detect_missing_packages() {
    for package in "${prerequists[@]}"; do
        if ! command -v "$package" &>/dev/null; then
            missing_packages+=("$package")
        fi
    done
}

perform_update() {
    if sudo apt update || sudo pacman -Sy || sudo dnf check-update || sudo yum check-update || brew update || pkg update; then
        logInfo "System updated\n"
    else
        logError "System update failed\n"
    fi
}


install_missing_packages() {
    perform_update
    for package in "${missing_packages[@]}"; do
        if sudo apt install -y "$package" || sudo pacman -S "$package" || sudo dnf install -y "$package" || sudo yum install -y "$package" || sudo brew install "$package" || pkg install "$package"; then
            logInfo "$package Installed\n"
        else
            logWarning "🚨 Please install the following packages first, then try again: $package 🚨" && exit
        fi
    done
}


backup_existing_zshrc_config() {
    if mv -n $HOME/.zshrc $HOME/.zshrc-backup-"$(date +"%Y-%m-%d")"; then # backup .zshrc
        logInfo -e "Backed up the current .zshrc to .zshrc-backup-date\n"
    fi
}

# -d checks if the directory exists
# git -C checks if the directory exists and runs the command in that directory
configure_ohmzsh() {
    if [ -d "$OH_MY_ZSH_FOLDER" ]; then
        logInfo "✅ oh-my-zsh is already installed\n"
        git -C "$OH_MY_ZSH_FOLDER" remote set-url origin "$OH_MY_ZSHR_REPO"
        export ZSH=$OH_MY_ZSH_FOLDER;
        git -C "$OH_MY_ZSH_FOLDER" pull
    elif [ -d "$HOME/.oh-my-zsh" ]; then
        logProgress "⏳ oh-my-zsh is already installed at '$HOME/.oh-my-zsh'. Moving it to '$HOME/.config/czsh/oh-my-zsh'"
        export ZSH=$OH_MY_ZSH_FOLDER;
        mv "$HOME/.oh-my-zsh" "$OH_MY_ZSH_FOLDER"
        git -C "$OH_MY_ZSH_FOLDER" remote set-url origin "$OH_MY_ZSHR_REPO"
        git -C "$OH_MY_ZSH_FOLDER" pull
    else
        git clone --depth=1 $OH_MY_ZSHR_REPO "$OH_MY_ZSH_FOLDER"
        export ZSH=$OH_MY_ZSH_FOLDER;
    fi
}

configure_autosuggestions() {
    if [ -d "$ZSH_AUTOSUGGESTION_PATH" ]; then
        git -C "$ZSH_AUTOSUGGESTION_PATH" pull
        logInfo "✅ zsh-autosuggestions updated\n"
    else
        git clone --depth=1 $AUTOSUGGESTIONS_PLUGIN_REPO "$ZSH_AUTOSUGGESTION_PATH"
        logInfo "✅ zsh-autosuggestions installed\n"
    fi
}

configure_zsh_codex() {
    
    logProgress "configuring zsh_codex\n"
    cp openaiapirc $HOME/.config/

    read -s -p "Enter your openai api key: "
    OPENAI_API_KEY=$REPLY

    sed -i "s/TOBEREPLEACED/$OPENAI_API_KEY/g" $HOME/.config/openaiapirc


    if [ -d "$ZSH_CODEX_PLUGIN_PATH" ]; then
        git -C "$ZSH_CODEX_PLUGIN_PATH" pull
    else
        pip3 install openai 
        git clone --depth=1 "$ZHS_CODEX_PLUGIN_REPO" "$ZSH_CODEX_PLUGIN_PATH"
    fi
}

configure_syntax_highlighting() {

    if [ -d "$ZSH_SYNTAX_HIGHLIGHTING_PATH" ]; then
     git -C $ZSH_SYNTAX_HIGHLIGHTING_PATH pull
    else
        git clone --depth=1 $ZSH_SYNTAX_HIGHLIGHTING_REPO $ZSH_SYNTAX_HIGHLIGHTING_PATH
    fi
}

configure_zsh_completions() {
    if [ -d $ZSH_COMPLETION_PLUGIN_PATH ]; then
        git -C $ZSH_COMPLETION_PLUGIN_PATH pull
    else
        git clone --depth=1 $ZSH_COMPLETIONS_REPO $ZSH_COMPLETION_PLUGIN_PATH
    fi
}

configure_zsh_history_substring_search() {
    if [ -d $ZSH_HISTORY_SUBSTRING_PLUGIN_PATH ]; then
        git -C $ZSH_HISTORY_SUBSTRING_PLUGIN_PATH pull 
    else
        git clone --depth=1 $ZSH_HISTORY_SUBSTRING_SEARCH_REPO $ZSH_HISTORY_SUBSTRING_PLUGIN_PATH
    fi
}

install_fzf() {
    if [ -d $FZF_INSTALLATION_PATH ]; then
        git -C $FZF_INSTALLATION_PATH pull
        $FZF_INSTALLATION_PATH/install --all --key-bindings --completion --no-update-rc
    else
        git clone --depth 1 $FZF_REPO $FZF_INSTALLATION_PATH
        $FZF_INSTALLATION_PATH/install --all --key-bindings --completion --no-update-rc
    fi

}

install_powerlevel10k() {
    if [ -d $POWERLEVEL_10K_PATH ]; then
        git -C $POWERLEVEL_10K_PATH pull
    else
        git clone --depth=1 $POWERLEVEL10K_REPO $POWERLEVEL_10K_PATH
    fi
}

install_lazydocker() {
    if [ -d $LAZYDOCKER_INSTALLATION_PATH ]; then
        git -C $LAZYDOCKER_INSTALLATION_PATH pull
        $LAZYDOCKER_INSTALLATION_PATH/scripts/install_update_linux.sh
    else
        git clone --depth 1 $LAZYDOCKER_REPO $LAZYDOCKER_INSTALLATION_PATH
        $LAZYDOCKER_INSTALLATION_PATH/scripts/install_update_linux.sh
    fi
}

install_fzf_tab() {
    if [ -d "$FZF_TAB_PLUGIN_PATH" ]; then
        git -C "$FZF_TAB_PLUGIN_PATH" pull
    else
        git clone --depth 1 $FZF_TAB_REPO $FZF_TAB_PLUGIN_PATH
    fi
}

install_marker() {
    if [ -d $MARKER_PATH ]; then
        git -C $MARKER_PATH pull
    else
        git clone --depth 1 $MARKER_REPO $HOME/.config/czsh/marker
    fi

}

install_todo() {
    if [ ! -L $HOME/.config/czsh/todo/bin/todo.sh ]; then
        logInfo "Installing todo.sh in $HOME/.config/czsh/todo\n"
        mkdir -p $HOME/.config/czsh/bin
        mkdir -p $HOME/.config/czsh/todo
        wget -q --show-progress "https://github.com/todotxt/todo.txt-cli/releases/download/v2.12.0/todo.txt_cli-2.12.0.tar.gz" -P $HOME/.config/czsh/
        tar xvf $HOME/.config/czsh/todo.txt_cli-2.12.0.tar.gz -C $HOME/.config/czsh/todo --strip 1 && rm $HOME/.config/czsh/todo.txt_cli-2.12.0.tar.gz
        ln -s -f $HOME/.config/czsh/todo/todo.sh $HOME/.config/czsh/bin/todo.sh # so only .../bin is included in $PATH
        ln -s -f $HOME/.config/czsh/todo/todo.cfg $HOME/.todo.cfg               # it expects it there or $HOME/todo.cfg or $HOME/.todo/config
    else
        echo -e "todo.sh is already instlled in $HOME/.config/czsh/todo/bin/\n"
    fi
}

copy_history() {

    if [ "$cp_hist_flag" = true ]; then
        echo -e "\nCopying bash_history to zsh_history\n"
        if command -v python &>/dev/null; then
            wget -q --show-progress https://gist.githubusercontent.com/muendelezaji/c14722ab66b505a49861b8a74e52b274/raw/49f0fb7f661bdf794742257f58950d209dd6cb62/bash-to-zsh-hist.py
            python bash-to-zsh-hist.py < $HOME/.bash_history >> $HOME/.zsh_history
        else
            if command -v python3 &>/dev/null; then
                wget -q --show-progress https://gist.githubusercontent.com/muendelezaji/c14722ab66b505a49861b8a74e52b274/raw/49f0fb7f661bdf794742257f58950d209dd6cb62/bash-to-zsh-hist.py
                python3 bash-to-zsh-hist.py < $HOME/.bash_history >> $HOME/.zsh_history
            else
                ech "Python is not installed, can't copy bash_history to zsh_history\n"
            fi
        fi
    else
        logWarning "\nNot copying bash_history to zsh_history, as --cp-hist or -c is not supplied\n"
    fi
}

finish_installation() {
    logInfo "Installation complete\n"
    if [ "$noninteractive_flag" = true ]; then
        logInfo "Installation complete, exit terminal and enter a new zsh session\n"
        logWarning "Make sure to change zsh to default shell by running: chsh -s $(which zsh)"
        logInfo "In a new zsh session manually run: build-fzf-tab-module"
    else
        logWarning "\nSudo access is needed to change default shell\n"

        if chsh -s "$(which zsh)" && /bin/zsh -i -c 'omz update'; then
            logInfo "Installation complete, exit terminal and enter a new zsh session"
            logWarning "In a new zsh session manually run: build-fzf-tab-module"
        else
            logError "Something is wrong, the password you entered might be wrong\n"

        fi
    fi
}



#############################################################################################
####################################### MAIN SCRIPT #########################################
#############################################################################################

detect_missing_packages

install_missing_packages


backup_existing_zshrc_config

logInfo "The setup will be installed in '$HOME/.config/czsh'\n"

logWarning "Place your personal zshrc config files under '$HOME/.config/czsh/zshrc/'\n"

mkdir -p $HOME/.config/czsh/zshrc

logInfo "Installing oh-my-zsh\n"

configure_ohmzsh


cp -f ./.zshrc $HOME/
cp -f ./czshrc.zsh $HOME/.config/czsh/

mkdir -p $HOME/.config/czsh/zshrc # PLACE YOUR ZSHRC CONFIGURATIONS OVER THERE
mkdir -p $HOME/.cache/zsh/        # this will be used to store .zcompdump zsh completion cache files which normally clutter $HOME
mkdir -p $HOME/.fonts             # Create .fonts if doesn't exist

if [ -f $HOME/.zcompdump ]; then
    mv $HOME/.zcompdump* $HOME/.cache/zsh/
fi

configure_autosuggestions

configure_syntax_highlighting

configure_zsh_completions

configure_zsh_history_substring_search

if [ "$zsh_codex_flag" = true ]; then
    configure_zsh_codex 
fi

install_powerlevel10k

install_marker

logProgress "Installing Nerd Fonts version of Hack, Roboto Mono, DejaVu Sans Mono\n"

if [ ! -f $HOME/.fonts/HackNerdFont-Regular.ttf ]; then
    wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf -P $HOME/.fonts/
fi

if [ ! -f $HOME/.fonts/RobotoMonoNerdFont-Regular.ttf ]; then
    wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/RobotoMonoNerdFont-Regular.ttf -P $HOME/.fonts/
fi

if [ ! -f $HOME/.fonts/DejaVuSansMNerdFont-Regular.ttf ]; then
    wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/DejaVuSansMNerdFont-Regular.ttf -P $HOME/.fonts/
fi

fc-cache -fv $HOME/.fonts

install_fzf

install_lazydocker


install_fzf_tab

install_marker

install_todo

copy_history

finish_installation

exit
