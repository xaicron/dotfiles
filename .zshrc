export LANG=ja_JP.UTF-8
case ${UID} in
0)
    LANG=C
    ;;
esac

# function path
fpath=($HOME/.zsh/func $fpath)

autoload -U compinit
compinit
setopt auto_pushd
setopt auto_cd
setopt correct
setopt cdable_vars

autoload colors
colors

export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt hist_ignore_dups
setopt share_history

# prompt
PROMPT="%B%{$fg[cyan]%}[%D %*] %#%{$fg[default]%}%b "
RPROMPT="%B[%{$fg[white]%}%/%{$fg[default]%}]%b"
SPROMPT="%B%{$fg[red]%}zsh: correct '%R' to '%r' [nyae]? : %{$fg[default]%}%b"

# alias
#alias ls='ls -G -w'
alias ll='ls -l'
alias la='ll -a'

alias minisync='minicpan -r http://ftp.yz.yamagata-u.ac.jp/pub/lang/cpan/ -l ~/minicpan'
alias gvim='env LANG=ja_JP.UTF-8 open -a /Applications/MacVim.app "$@"'
alias cpan-uninstall='\perl -MExtUtils::Install -MExtUtils::Installed -e "unshift@ARGV,new ExtUtils::Installed;sub a{\@ARGV};uninstall((eval{a->[0]->packlist(a->[1])}||do{require CPAN;a->[0]->packlist(CPAN::Shell->expandany(a->[1])->distribution->base_id=~m/(.*)-[^-]+$/)})->packlist_file,1,a->[2])"'

# set path
export PATH=/usr/local/bin:/opt/local/bin:/opt/local/sbin:$PATH
export PATH=$PATH:$HOME/.gem/ruby/1.9.1/bin
export MANPATH=/usr/local/man:/opt/local/man:$MANPATH

# set color
export CLICOLOR=1
export LSCOLORS=DxGxcxdxCxegedabagacad

# perl path
eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)

# ruby path
export RUBYLIB=$HOME/.gem/ruby/1.9.1/lib

# path uniq
PATH=$(perl -e '%h; print join ":", grep { !$h{$_}++ } split /:/, $ENV{PATH}')

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

