# set lang
export LANG=ja_JP.UTF-8
case ${UID} in
0)
    LANG=C
    ;;
esac

# function path
if [ `uname` = "Darwin" ]; then
    autoload -Uz run-help
    HELPDIR=${HOMEBREW_PREFIX}/share/zsh/help

    if [ -e "${HOMEBREW_PREFIX}/share/zsh-completions" ]; then
        fpath=(${HOMEBREW_PREFIX}/share/zsh-completions $fpath)
    fi
    if [ -e "${HOMEBREW_PREFIX}/share/zsh/site-functions" ]; then
        fpath=(${HOMEBREW_PREFIX}/share/zsh/site-functions $fpath)
    fi
fi

fpath=($HOME/.zsh/func $fpath)

autoload -Uz compinit
compinit -u
autoload -Uz colors
colors

# options
setopt auto_pushd
setopt auto_cd
setopt correct
#setopt cdable_vars
setopt complete_aliases
setopt list_packed
setopt list_types
setopt pushd_ignore_dups
setopt auto_param_slash
setopt mark_dirs
setopt auto_menu
setopt auto_param_keys
setopt interactive_comments
setopt magic_equal_subst
setopt complete_in_word
setopt always_last_prompt
setopt print_eight_bit
#setopt extended_glob
setopt globdots
setopt no_flow_control
setopt rm_star_silent
setopt noclobber
setopt no_global_rcs # important on mac

# completions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' use-cache true
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:default' menu select=3

# history
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt hist_ignore_all_dups
setopt share_history
setopt hist_reduce_blanks

# key binds
bindkey -e
zmodload zsh/complist
bindkey "^?"    backward-delete-char
bindkey "^H"    backward-delete-char
bindkey "^[[3~" delete-char
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey '^p'    history-beginning-search-backward
bindkey '^n'    history-beginning-search-forward
#bindkey -v
#bindkey -M menuselect 'h' vi-backward-char
#bindkey -M menuselect 'j' vi-down-line-or-history
#bindkey -M menuselect 'k' vi-up-line-or-history
#bindkey -M menuselect 'l' vi-forward-char

# prompt
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats '%b'
autoload -Uz is-at-least
if is-at-least 4.3.1; then
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' stagedstr "+:"
    zstyle ':vcs_info:git:*' unstagedstr "-:"
    zstyle ':vcs_info:git:*' formats '%u%b'
    zstyle ':vcs_info:git:*' actionformats '%c%u%b|%a'
fi

autoload -Uz add-zsh-hook
setopt prompt_subst
function _git_prompt () {
    LANG=C vcs_info;
    local _info=
    if [ -n "$vcs_info_msg_0_" ]; then
        local _not_pushed=$(_git_not_pushed);
        _info="%{$fg[red]%}(${_not_pushed}${vcs_info_msg_0_})%{$fg[default]%} "
    fi
    PROMPT="%B${_info}%{$fg[cyan]%}[%D %*]%{$fg[cyan]%}"
    if [ `uname` = "Darwin" ]; then
        PROMPT="${PROMPT}%{$fg[default]%}%b "
    else
        PROMPT="${PROMPT}%#%{$fg[default]%}%b "
    fi
    if [ -n "${REMOTEHOST}${SSH_CONNECTION}" ]; then
        PROMPT="%B%{$fg[white]%}(${USER}@${HOST%%.*}) ${PROMPT}"
    fi
    if [ -n "${AWS_PROFILE}" ]; then
        PROMPT="%B%{$fg[white]%}(AWS_PROFILE=${AWS_PROFILE}) ${PROMPT}"
    fi
}

# TODO counting an ahead
function _git_not_pushed() {
    if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]; then
        head="$(git rev-parse HEAD 2>/dev/null)"
        for x in $(git rev-parse --remotes)
        do
            if [ "$head" = "$x" ]; then
                return 0
            fi
        done
        echo "*:"
    fi
    return 0
}

add-zsh-hook precmd _git_prompt

export RPROMPT="%B[%{$fg[white]%}%/%{$fg[default]%}]%b"
export SPROMPT="%B%{$fg[default]%}zsh: correct '%{$fg[red]%}%R%{$fg[default]%}' to '%{$fg[green]%}%r%{$fg[default]%}' [nyae]? : %{$fg[default]%}%b"

# functions
source ~/.zsh/functions

# alias
source ~/.zsh/alias

# perl env
export PERL_CPANM_OPT="--skip-installed"

# git env
export GIT_EDITOR=vim

# general env
export EDITOR=vim
export PAGER="less -R"

# PATH
export PATH=$PATH:/usr/local/opt/coreutils/libexec/gnubin
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export PATH=$HOME/bin:$HOME/local/bin:$PATH

# perl path
if [ -f ~/perl5/perlbrew/etc/bashrc ]; then
    source ~/perl5/perlbrew/etc/bashrc
fi

# set color
export CLICOLOR=1
export LSCOLORS=DxGxcxdxCxegedabagacad
which dircolors > /dev/null
if [ $? -eq 0 ]; then
    if [ ! -f ~/.dir_colors ]; then
        dircolors -p > ~/.dir_colors
    fi
    eval `dircolors -b ~/.dir_colors`
fi

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# load local setting
if [ -f ~/.zsh_local ]; then
    source ~/.zsh_local
fi

if type rbenv > /dev/null; then
    eval "$(rbenv init - zsh)"
fi

if type direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
alias emulator=$HOME/Library/Android/sdk/emulator/emulator
export JAVA_HOME="$HOME/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export ES_JAVA_HOME=$(find "/opt/homebrew/Cellar/openjdk/" -path '*libexec/openjdk.jdk/Contents/Home' | head -1)

# uniq path
typeset -U path cdpath fpath manpath
#alias pm-uninstall=cpanm -U

if [ -d ~/.plenv ]; then
    export PATH="$HOME/.plenv/bin:$PATH"
    eval "$(plenv init -)"
fi

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C ${HOMEBREW_PREFIX}/bin/terraform terraform
# source ~/.mysqlenv/etc/bashrc

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

# bun completions
[ -s "/Users/shimada.yuji/.bun/_bun" ] && source "/Users/shimada.yuji/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ngrok
if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi

# proto
# export PROTO_HOME="$HOME/.proto"
# export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"

