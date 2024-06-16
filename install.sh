#!/bin/bash

#############################################################################################
######################################### VARIABLES #########################################
#############################################################################################
# Flags to determine if the arguments were passed
cp_hist_flag=false
noninteractive_flag=false
zsh_codex_flag=false

# Loop through all arguments
for arg in "$@"; do
    case $arg in
    --cp-hist | -c)
        cp_hist_flag=true
        ;;
    --non-interactive | -n)
        noninteractive_flag=true
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
####################################### FUNCTIONS #########################################
#############################################################################################

prerequists=("zsh" "git" "wget", "autoconf", "batcat", "curl")
missing_packages=()

detect_missing_packages() {
    for i in "${prerequists[@]}"; do
        if ! command -v $i &>/dev/null; then
            not_installed+=($i)
        fi
    done
}

install_missing_packages() {
    for package in "${missing_packages[@]}"; do
        if sudo apt install -y $package || sudo pacman -S $package || sudo dnf install -y $package || sudo yum install -y $package || sudo brew install $package || pkg install $package; then
            echo -e "$package Installed\n"
        else
            echo -e "Please install the following packages first, then try again: $package \n" && exit
        fi
    done
}

check_quickzsh_installation() {
    if [ -d ~/.quickzsh ]; then
        echoIULRed -e "\n PREVIOUS SETUP FOUND AT '~/.quickzsh'. PLEASE MANUALLY MOVE ANY FILES YOU'D LIKE TO '~/.config/szsh' \n"
        exit
    fi
}

backup_existing_zshrc_config() {
    # -n prevents overwriting existing files
    if mv -n ~/.zshrc ~/.zshrc-backup-$(date +"%Y-%m-%d"); then # backup .zshrc
        echoGreen -e "Backed up the current .zshrc to .zshrc-backup-date\n"
    fi
}

# -d checks if the directory exists
# git -C checks if the directory exists and runs the command in that directory
configure_ohmzsh() {
    if [ -d ~/.config/szsh/oh-my-zsh ]; then
        echoGreen "oh-my-zsh is already installed\n"
        git -C ~/.config/szsh/oh-my-zsh remote set-url origin https://github.com/ohmyzsh/ohmyzsh.git
    elif [ -d ~/.oh-my-zsh ]; then
        echo -e "oh-my-zsh in already installed at '~/.oh-my-zsh'. Moving it to '~/.config/szsh/oh-my-zsh'"
        export ZSH="$HOME/.config/szsh/oh-my-zsh"
        mv ~/.oh-my-zsh ~/.config/szsh/oh-my-zsh
        git -C ~/.config/szsh/oh-my-zsh remote set-url origin https://github.com/ohmyzsh/ohmyzsh.git
    else
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.config/szsh/oh-my-zsh
    fi
}

check_autosuggestions() {
    if [ -d ~/.config/szsh/oh-my-zsh/plugins/zsh-autosuggestions ]; then
        git -C ~/.config/szsh/oh-my-zsh/plugins/zsh-autosuggestions pull
        echoGreen "zsh-autosuggestions updated\n"
    else
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.config/szsh/oh-my-zsh/plugins/zsh-autosuggestions
        echoGreen "zsh-autosuggestions installed\n"
    fi

}

check_zsh_codex() {
    if [ -d ~/.config/szsh/oh-my-zsh/plugins/zsh_codex ]; then
        git -C ~/.config/szsh/oh-my-zsh/plugins/zsh_codex pull
    else
        git clone --depth=1 https://github.com/tom-doerr/zsh_codex.git ~/.config/szsh/oh-my-zsh/plugins/zsh_codex
    fi
}

check_syntax_highlighting() {

    if [ -d ~/.config/szsh/oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
        cd ~/.config/szsh/oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull
    else
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/szsh/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    fi
}

check_zsh_completions() {
    if [ -d ~/.config/szsh/oh-my-zsh/custom/plugins/zsh-completions ]; then
        git -C ~/.config/szsh/oh-my-zsh/custom/plugins/zsh-completions pull
    else
        git clone --depth=1 https://github.com/zsh-users/zsh-completions ~/.config/szsh/oh-my-zsh/custom/plugins/zsh-completions
    fi
}

check_zsh_history_substring_search() {
    if [ -d ~/.config/szsh/oh-my-zsh/custom/plugins/zsh-history-substring-search ]; then
        cd ~/.config/szsh/oh-my-zsh/custom/plugins/zsh-history-substring-search && git pull
    else
        git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ~/.config/szsh/oh-my-zsh/custom/plugins/zsh-history-substring-search
    fi
}

install_fzf() {
    if [ -d ~/.~/.config/szsh/fzf ]; then
        git -C ~/.config/szsh/fzf pull
        ~/.config/szsh/fzf/install --all --key-bindings --completion --no-update-rc
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.config/szsh/fzf
        ~/.config/szsh/fzf/install --all --key-bindings --completion --no-update-rc
    fi

}

install_powerlevel10k() {
    if [ -d ~/.config/szsh/oh-my-zsh/custom/themes/powerlevel10k ]; then
        cd ~/.config/szsh/oh-my-zsh/custom/themes/powerlevel10k && git pull
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.config/szsh/oh-my-zsh/custom/themes/powerlevel10k
    fi
}

install_lazydocker() {
    if [ -d ~/.~/.config/szsh/lazydocker ]; then
        cd ~/.config/szsh/lazydocker && git pull
        ~/.config/szsh/lazydocker/install_update_linux.sh
    else
        git clone --depth 1 https://github.com/jesseduffield/lazydocker.git ~/.config/szsh/lazydocker
        ~/.config/szsh/lazydocker/install_update_linux.sh
    fi
}

install_k() {
    if [ -d ~/.config/szsh/oh-my-zsh/custom/plugins/k ]; then
        git -C ~/.config/szsh/oh-my-zsh/custom/plugins/k pull
    else
        git clone --depth 1 https://github.com/supercrabtree/k ~/.config/szsh/oh-my-zsh/custom/plugins/k
    fi
}

install_fzf_tab() {
    if [ -d ~/.config/szsh/oh-my-zsh/custom/plugins/fzf-tab ]; then
        cd ~/.config/szsh/oh-my-zsh/custom/plugins/fzf-tab && git pull
    else
        git clone --depth 1 https://github.com/Aloxaf/fzf-tab ~/.config/szsh/oh-my-zsh/custom/plugins/fzf-tab
    fi
}

install_marker() {
    if [ -d ~/.config/szsh/marker ]; then
        git -C ~/.config/szsh/marker pull
    else
        git clone --depth 1 https://github.com/jotyGill/marker ~/.config/szsh/marker
    fi

}

#############################################################################################
####################################### Utilities ###########################################
#############################################################################################

echoIULRed() {
    echo -e "\\033[3;4;31m$*\\033[m"
}

echoBlue() {
    echo -e "\\033[34m$*\\033[m"
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
####################################### MAIN SCRIPT #########################################
#############################################################################################

detect_missing_packages

install_missing_packages

check_quickzsh_installation

backup_existing_zshrc_config

echoGreen -e "The setup will be installed in '~/.config/szsh'\n"
echoYellow -e "Place your personal zshrc config files under '~/.config/szsh/zshrc/'\n"
mkdir -p ~/.config/szsh/zshrc

echoGreen "Installing oh-my-zsh\n"

configure_ohmzsh

cp -f .zshrc ~/
cp -f szshrc.zsh ~/.config/szsh/

mkdir -p ~/.config/szsh/zshrc # PLACE YOUR ZSHRC CONFIGURATIONS OVER THERE
mkdir -p ~/.cache/zsh/        # this will be used to store .zcompdump zsh completion cache files which normally clutter $HOME
mkdir -p ~/.fonts             # Create .fonts if doesn't exist

if [ -f ~/.zcompdump ]; then
    mv ~/.zcompdump* ~/.cache/zsh/
fi

check_autosuggestions

check_zsh_codex

check_syntax_highlighting

check_zsh_completions

check_zsh_history_substring_search

install_marker
# INSTALL FONTS

echoCyan "Installing Nerd Fonts version of Hack, Roboto Mono, DejaVu Sans Mono\n"

wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf -P ~/.fonts/
wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/RobotoMonoNerdFont-Regular.ttf -P ~/.fonts/
wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/DejaVuSansMNerdFont-Regular.ttf -P ~/.fonts/

fc-cache -fv ~/.fonts

install_fzf

install_powerlevel10k

install_lazydocker

install_k

install_fzf_tab

install_marker

# if git clone --depth 1 https://github.com/todotxt/todo.txt-cli.git ~/.config/szsh/todo; then :
# else
#     cd ~/.config/szsh/todo && git fetch --all && git reset --hard origin/master
# fi
# mkdir ~/.config/szsh/todo/bin ; cp -f ~/.config/szsh/todo/todo.sh ~/.config/szsh/todo/bin/todo.sh # cp todo.sh to ./bin so only it is included in $PATH
# #touch ~/.todo/config     # needs it, otherwise spits error , yeah a bug in todo
# ln -s ~/.config/szsh/todo ~/.todo


if [ ! -L ~/.config/szsh/todo/bin/todo.sh ]; then
    echoGreen "Installing todo.sh in ~/.config/szsh/todo\n"
    mkdir -p ~/.config/szsh/bin
    mkdir -p ~/.config/szsh/todo
    wget -q --show-progress "https://github.com/todotxt/todo.txt-cli/releases/download/v2.12.0/todo.txt_cli-2.12.0.tar.gz" -P ~/.config/szsh/
    tar xvf ~/.config/szsh/todo.txt_cli-2.12.0.tar.gz -C ~/.config/szsh/todo --strip 1 && rm ~/.config/szsh/todo.txt_cli-2.12.0.tar.gz
    ln -s -f ~/.config/szsh/todo/todo.sh ~/.config/szsh/bin/todo.sh # so only .../bin is included in $PATH
    ln -s -f ~/.config/szsh/todo/todo.cfg ~/.todo.cfg               # it expects it there or ~/todo.cfg or ~/.todo/config
else
    echo -e "todo.sh is already instlled in ~/.config/szsh/todo/bin/\n"
fi
if [ "$cp_hist_flag" = true ]; then
    echo -e "\nCopying bash_history to zsh_history\n"
    if command -v python &>/dev/null; then
        wget -q --show-progress https://gist.githubusercontent.com/muendelezaji/c14722ab66b505a49861b8a74e52b274/raw/49f0fb7f661bdf794742257f58950d209dd6cb62/bash-to-zsh-hist.py
        cat ~/.bash_history | python bash-to-zsh-hist.py >>~/.zsh_history
    else
        if command -v python3 &>/dev/null; then
            wget -q --show-progress https://gist.githubusercontent.com/muendelezaji/c14722ab66b505a49861b8a74e52b274/raw/49f0fb7f661bdf794742257f58950d209dd6cb62/bash-to-zsh-hist.py
            cat ~/.bash_history | python3 bash-to-zsh-hist.py >>~/.zsh_history
        else
            echo "Python is not installed, can't copy bash_history to zsh_history\n"
        fi
    fi
else
    echo -e "\nNot copying bash_history to zsh_history, as --cp-hist or -c is not supplied\n"
fi

if [ "$noninteractive_flag" = true ]; then
    echo -e "Installation complete, exit terminal and enter a new zsh session\n"
    echo -e "Make sure to change zsh to default shell by running: chsh -s $(which zsh)"
    echo -e "In a new zsh session manually run: build-fzf-tab-module"
else
    # source ~/.zshrc
    echo -e "\nSudo access is needed to change default shell\n"

    if chsh -s $(which zsh) && /bin/zsh -i -c 'omz update'; then
        echo -e "Installation complete, exit terminal and enter a new zsh session"
        echo -e "In a new zsh session manually run: build-fzf-tab-module"
    else
        echo -e "Something is wrong"

    fi
fi
exit
