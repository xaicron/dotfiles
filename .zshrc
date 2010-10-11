# set lang
export LANG=ja_JP.UTF-8
case ${UID} in
0)
    LANG=C
    ;;
esac

# function path
fpath=($HOME/.zsh/func $fpath)

autoload -Uz compinit
compinit
autoload -Uz colors
colors

# options
setopt auto_pushd
setopt auto_cd
setopt correct
setopt cdable_vars
setopt complete_aliases
setopt list_packed
setopt list_types
setopt pushd_ignore_dups

# completions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
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
zstyle ':vcs_info:*' formats '%{$fg[red]%}(%b)%{$fg[default]%} '

setopt prompt_subst
precmd () {
    LANG=C vcs_info;
    PROMPT="%B${vcs_info_msg_0_}%{$fg[cyan]%}[%D %*]%{$fg[cyan]%}%#%{$fg[default]%}%b "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && PROMPT="%B%{$fg[white]%}(${USER}@${HOST%%.*}) ${PROMPT}"
}
#export PROMPT="%B${vcs_info_msg_0_}%{$fg[cyan]%}[%D %*] %#%{$fg[default]%}%b "
export RPROMPT="%B[%{$fg[white]%}%/%{$fg[default]%}]%b"
export SPROMPT="%B%{$fg[default]%}zsh: correct '%{$fg[red]%}%R%{$fg[default]%}' to '%{$fg[green]%}%r%{$fg[default]%}' [nyae]? : %{$fg[default]%}%b"

# alias
alias ls='ls -vF'
if [ $OSTYPE = "linux-gnu" ]; then
    alias ls='ls -vF --color=auto'
fi
alias ll='ls -l'
alias la='ll -a'

which colordiff > /dev/null 
if [ $? -eq 0 ]; then
    alias diff='colordiff'
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

# perl path
if [ -f ~/perl5/perlbrew/etc/bashrc ]; then
    source ~/perl5/perlbrew/etc/bashrc
fi

# perl env
export PERL_CPANM_DEV=1
export PERL_CPANM_OPT='--skip-installed'

# git env
export GIT_EDITOR=vi

# general env
export EDITOR=vi

# PATH
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export PATH=$HOME/bin:$PATH

# screen
#if [ "$TERM" = "screen" ]; then
#    chpwd () { echo -n "_`dirs`\\" }
#    preexec() {
#        # see [zsh-workers:13180]
#        # http://www.zsh.org/mla/workers/2000/msg03993.html
#        emulate -L zsh
#        local -a cmd; cmd=(${(z)2})
#        case $cmd[1] in
#            fg)
#                if (( $#cmd == 1 )); then
#                    cmd=(builtin jobs -l %+)
#                else
#                    cmd=(builtin jobs -l $cmd[2])
#                fi
#                ;;
#            %*) 
#                cmd=(builtin jobs -l $cmd[1])
#                ;;
#            cd)
#                if (( $#cmd == 2)); then
#                    cmd[1]=$cmd[2]
#                fi
#                ;&
#            *)
#                echo -n "k$cmd[1]:t\\"
#                return
#                ;;
#        esac
#
#        local -A jt; jt=(${(kv)jobtexts})
#
#        $cmd >>(read num rest
#            cmd=(${(z)${(e):-\$jt$num}})
#            echo -n "k$cmd[1]:t\\") 2>/dev/null
#    }
#    chpwd
#fi

# load local setting
if [ -f ~/.zsh_local ]; then
    source ~/.zsh_local
fi

# uniq path
typeset -U path

