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

# key binds
bindkey -v
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# prompt
export PROMPT="%B%{$fg[cyan]%}[%D %*] %#%{$fg[default]%}%b "
export RPROMPT="%B[%{$fg[white]%}%/%{$fg[default]%}]%b"
export SPROMPT="%B%{$fg[default]%}zsh: correct '%{$fg[red]%}%R%{$fg[default]%}' to '%{$fg[green]%}%r%{$fg[default]%}' [nyae]? : %{$fg[default]%}%b"

# alias
alias ls='ls -vF'
if [ $OSTYPE = "linux-gnu" ]; then
    alias ls='ls -vF --color=auto'
fi
alias ll='ls -l'
alias la='ll -a'

# set color
export CLICOLOR=1
export LSCOLORS=DxGxcxdxCxegedabagacad

# perl path
if [ -f ~/perl5/perlbrew/etc/bashrc ]; then
    source ~/perl5/perlbrew/etc/bashrc
fi

# perl env
export PERL_CPANM_DEV=1

# git env
export GIT_EDITOR=vi

# general env
export EDITOR=vi

# screen
if [ "$TERM" = "screen" ]; then
    chpwd () { echo -n "_`dirs`\\" }
    preexec() {
        # see [zsh-workers:13180]
        # http://www.zsh.org/mla/workers/2000/msg03993.html
        emulate -L zsh
        local -a cmd; cmd=(${(z)2})
        case $cmd[1] in
            fg)
                if (( $#cmd == 1 )); then
                    cmd=(builtin jobs -l %+)
                else
                    cmd=(builtin jobs -l $cmd[2])
                fi
                ;;
            %*) 
                cmd=(builtin jobs -l $cmd[1])
                ;;
            cd)
                if (( $#cmd == 2)); then
                    cmd[1]=$cmd[2]
                fi
                ;&
            *)
                echo -n "k$cmd[1]:t\\"
                return
                ;;
        esac

        local -A jt; jt=(${(kv)jobtexts})

        $cmd >>(read num rest
            cmd=(${(z)${(e):-\$jt$num}})
            echo -n "k$cmd[1]:t\\") 2>/dev/null
    }
    chpwd
fi

# load local setting
if [ -f ~/.zsh_local ]; then
    source ~/.zsh_local
fi

# uniq path
typeset -U path

