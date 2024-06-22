#!/bin/bash


cp_hist_flag=false
noninteractive_flag=true
zsh_codex_flag=false


OH_MY_ZSH_FOLDER=$HOME/.config/szsh/oh-my-zsh
OHMYZSH_PLUGIN_PATH="$OH_MY_ZSH_FOLDER/plugins"


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

FZF_TAB_PLUGIN_PATH="$OHMYZSH_PLUGIN_PATH/fzf-tab"
ZSH_SYNTAX_HIGHLIGHTING_PATH="$OHMYZSH_PLUGIN_PATH/zsh-syntax-highlighting"
ZSH_AUTOSUGGESTION_PATH="$OHMYZSH_PLUGIN_PATH/zsh-autosuggestions"
POWERLEVEL_10K_PATH=$OH_MY_ZSH_FOLDER/themes/powerlevel10k
ZSH_CODEX_PLUGIN_PATH="$OHMYZSH_PLUGIN_PATH/zsh_codex"
ZSH_COMPLETION_PLUGIN_PATH="$OHMYZSH_PLUGIN_PATH/zsh-completions"
ZSH_HISTORY_SUBSTRING_PLUGIN_PATH=$OHMYZSH_PLUGIN_PATH/zsh-history-substring-search


################################################################################################
####################################### INSTALLATION PATHS #####################################
################################################################################################
FZF_INSTALLATION_PATH=$HOME/.config/szsh/fzf    
LAZYDOCKER_INSTALLATION_PATH=$HOME/.config/szsh/lazydocker
MARKER_PATH=$HOME/.config/szsh/marker


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

echoYellow() {
    echo -e "\\033[33m$*\\033[m"
}

echoGreen() {
    echo -e "\\033[32m$*\\033[m"
}

echoRed() {
    echo -e "\\033[31m$*\\033[m"
}

echoCyan() {
    echo -e "\\033[36m$*\\033[m"
}

#############################################################################################
####################################### FUNCTIONS #########################################
#############################################################################################

prerequists=("zsh" "git" "wget" "bat" "curl" "python3-pip")
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
        echoGreen "System updated\n"
    else
        echoRed "System update failed\n"
    fi
}


install_missing_packages() {
    perform_update
    for package in "${missing_packages[@]}"; do
        if sudo apt install -y "$package" || sudo pacman -S "$package" || sudo dnf install -y "$package" || sudo yum install -y "$package" || sudo brew install "$package" || pkg install "$package"; then
            echoGreen "$package Installed\n"
        else
            echoYellow "Please install the following packages first, then try again: $package \n" && exit
        fi
    done
}


backup_existing_zshrc_config() {
    if mv -n $HOME/.zshrc $HOME/.zshrc-backup-"$(date +"%Y-%m-%d")"; then # backup .zshrc
        echoGreen -e "Backed up the current .zshrc to .zshrc-backup-date\n"
    fi
}

# -d checks if the directory exists
# git -C checks if the directory exists and runs the command in that directory
configure_ohmzsh() {
    if [ -d "$OH_MY_ZSH_FOLDER" ]; then
        echoGreen "oh-my-zsh is already installed\n"
        git -C "$OH_MY_ZSH_FOLDER" remote set-url origin "$OH_MY_ZSHR_REPO" pull
    elif [ -d "$HOME/.oh-my-zsh" ]; then
        echoCyan "oh-my-zsh in already installed at '$HOME/.oh-my-zsh'. Moving it to '$HOME/.config/szsh/oh-my-zsh'"
        export ZSH="$HOME/.config/szsh/oh-my-zsh"
        mv "$HOME/.oh-my-zsh" "$OH_MY_ZSH_FOLDER"
        git -C "$OH_MY_ZSH_FOLDER" remote set-url origin "$OH_MY_ZSHR_REPO" pull
    else
        git clone --depth=1 $OH_MY_ZSHR_REPO "$OH_MY_ZSH_FOLDER"
    fi
}

configure_autosuggestions() {
    if [ -d "$ZSH_AUTOSUGGESTION_PATH" ]; then
        git -C "$ZSH_AUTOSUGGESTION_PATH" pull
        echoGreen "zsh-autosuggestions updated\n"
    else
        git clone --depth=1 $AUTOSUGGESTIONS_PLUGIN_REPO "$ZSH_AUTOSUGGESTION_PATH"
        echoGreen "zsh-autosuggestions installed\n"
    fi

}

configure_zsh_codex() {

    if [ -f "$HOME/.config/openaiapirc" ];
    then
        echo -e "openai api key already exists\n"
    else
        echo -e "export OPENAI_API_KEY=$1" > $HOME/.config/openaiapirc
    fi

    if [ -d "$ZSH_CODEX_PLUGIN_PATH" ]; then
        git -C "$ZSH_CODEX_PLUGIN_PATH" pull
    else
        pip3 install openai
        git clone --depth=1 "$ZHS_CODEX_PLUGIN_REPO" "$ZSH_CODEX_PLUGIN_PATH"
    fi
}

configure_syntax_highlighting() {

    if [ -d "$ZSH_SYNTAX_HIGHLIGHTING_PATH" ]; then
        cd "$ZSH_SYNTAX_HIGHLIGHTING_PATH" && git pull
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
        cd $ZSH_HISTORY_SUBSTRING_PLUGIN_PATH && git pull
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
        cd $POWERLEVEL_10K_PATH && git pull
    else
        git clone --depth=1 $POWERLEVEL10K_REPO $POWERLEVEL_10K_PATH
    fi
}

install_lazydocker() {
    if [ -d $LAZYDOCKER_INSTALLATION_PATH ]; then
        cd $LAZYDOCKER_INSTALLATION_PATH && git pull
        $LAZYDOCKER_INSTALLATION_PATH/install_update_linux.sh
    else
        git clone --depth 1 $LAZYDOCKER_REPO $LAZYDOCKER_INSTALLATION_PATH
        $LAZYDOCKER_INSTALLATION_PATH/install_update_linux.sh
    fi
}

install_fzf_tab() {
    if [ -d "$FZF_TAB_PLUGIN_PATH" ]; then
        cd "$FZF_TAB_PLUGIN_PATH" && git pull
    else
        git clone --depth 1 $FZF_TAB_REPO $FZF_TAB_PLUGIN_PATH
    fi
}

install_marker() {
    if [ -d $MARKER_PATH ]; then
        git -C $MARKER_PATH pull
    else
        git clone --depth 1 $MARKER_REPO $HOME/.config/szsh/marker
    fi

}

install_todo() {
    if [ ! -L $HOME/.config/szsh/todo/bin/todo.sh ]; then
        echoGreen "Installing todo.sh in $HOME/.config/szsh/todo\n"
        mkdir -p $HOME/.config/szsh/bin
        mkdir -p $HOME/.config/szsh/todo
        wget -q --show-progress "https://github.com/todotxt/todo.txt-cli/releases/download/v2.12.0/todo.txt_cli-2.12.0.tar.gz" -P $HOME/.config/szsh/
        tar xvf $HOME/.config/szsh/todo.txt_cli-2.12.0.tar.gz -C $HOME/.config/szsh/todo --strip 1 && rm $HOME/.config/szsh/todo.txt_cli-2.12.0.tar.gz
        ln -s -f $HOME/.config/szsh/todo/todo.sh $HOME/.config/szsh/bin/todo.sh # so only .../bin is included in $PATH
        ln -s -f $HOME/.config/szsh/todo/todo.cfg $HOME/.todo.cfg               # it expects it there or $HOME/todo.cfg or $HOME/.todo/config
    else
        echo -e "todo.sh is already instlled in $HOME/.config/szsh/todo/bin/\n"
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
        echoYellow "\nNot copying bash_history to zsh_history, as --cp-hist or -c is not supplied\n"
    fi
}

finish_installation() {
    echoGreen "Installation complete\n"
    if [ "$noninteractive_flag" = true ]; then
        echoGreen "Installation complete, exit terminal and enter a new zsh session\n"
        echoYellow "Make sure to change zsh to default shell by running: chsh -s $(which zsh)"
        echoGreen "In a new zsh session manually run: build-fzf-tab-module"
    else
        echoYellow "\nSudo access is needed to change default shell\n"

        if chsh -s "$(which zsh)" && /bin/zsh -i -c 'omz update'; then
            echoGreen "Installation complete, exit terminal and enter a new zsh session"
            echoYellow "In a new zsh session manually run: build-fzf-tab-module"
        else
            echoIULRed "Something is wrong, the password you entered might be wrong\n"

        fi
    fi
}



#############################################################################################
####################################### MAIN SCRIPT #########################################
#############################################################################################

detect_missing_packages

install_missing_packages

configure_quickzsh_installation

backup_existing_zshrc_config

echoGreen "The setup will be installed in '$HOME/.config/szsh'\n"

echoYellow "Place your personal zshrc config files under '$HOME/.config/szsh/zshrc/'\n"

mkdir -p $HOME/.config/szsh/zshrc

echoGreen "Installing oh-my-zsh\n"

configure_ohmzsh

cp -f .zshrc $HOME/
cp -f szshrc.zsh $HOME/.config/szsh/

mkdir -p $HOME/.config/szsh/zshrc # PLACE YOUR ZSHRC CONFIGURATIONS OVER THERE
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
    echoCyan "configuring zsh_codex\n"
    read -s -p "Enter your zsh_codex" SECRET_KEY

    export BASE_URL=${BASE_URL:-"https://api.groq.com/openai/v1"}
    export MODEL=${MODEL:-"https://api.groq.com/openai/v1"}

    configure_zsh_codex "$TOKEN"
fi


install_powerlevel10k

install_marker

echoCyan "Installing Nerd Fonts version of Hack, Roboto Mono, DejaVu Sans Mono\n"

wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf -P $HOME/.fonts/
wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/RobotoMonoNerdFont-Regular.ttf -P $HOME/.fonts/
wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/DejaVuSansMNerdFont-Regular.ttf -P $HOME/.fonts/

fc-cache -fv $HOME/.fonts

install_fzf

install_lazydocker

install_k

install_fzf_tab

install_marker

install_todo

copy_history

finish_installation

exit
