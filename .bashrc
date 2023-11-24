# globstar for **/*.ext
shopt -s globstar
# append to history on every prompt
shopt -s histappend

# PROMPT_COMMAND="history -a;history -c;history -r;$PROMPT_COMMAND"
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
# always expand aliases, even in dumb terminals
shopt -s expand_aliases
# testandrun
testandrun(){
    for arg in "$@"; do
        test -r "$arg" && source "$arg"
    done
}

# export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3

export ASYNC_TEST_TIMEOUT=15

# export PATH=$HOME/bin:$PATH
# export OLDPATH=$PATH
test -d $HOME/bin && export PATH=$HOME/bin:$PATH
test -d $HOME/Dropbox/bin && export PATH=$HOME/Dropbox/bin:$PATH
test -d $HOME/Dropbox/bin && chmod +x $HOME/Dropbox/bin/*
export OLDPATH=$PATH
for add in add drop; do
    for name in PATH PYTHONPATH LD_LIBRARY_PATH DYLD_LIBRARY_PATH; do
        if [ ! -z "$(which editenv)" ]; then
            eval "$add$name(){
            export TMPVAR=\`editenv $name $add \$@\`
            test -z \"\$TMPVAR\" || export $name=\$TMPVAR
            hash -r
            }"
        else
            eval "add$name(){
                for p in \$@; do
                    test -d \$p && export $name=\$p:\$$name
                done
            }"
            eval "drop$name(){}"
        fi
    done
done
alias addLD=addLD_LIBRARY_PATH
alias dropLD=dropLD_LIBRARY_PATH
alias addDYLD=addDYLD_LIBRARY_PATH
alias dropDYLD=dropDYLD_LIBRARY_PATH

for pre in LD DYLD; do
    # add$pre\_LIBRARY_PATH /sw/lib /opt/*/lib
    # add$pre\_LIBRARY_PATH /usr/local/lib /usr/local/*/lib /usr/local/*/lib64 ~/usr/local/lib ~/usr/local/lib/vtk*   2>/dev/null
    true
done

# setup the PATH

addPATH $HOME/Dropbox/scripts
addPATH /opt/pypy/bin
addPATH $HOME/.cabal/bin
addPATH /usr/local/share/npm/bin
addPATH /usr/bin /usr/*/bin /usr/local/*/bin /opt/homebrew/bin /opt/local/bin /opt/local/*/bin $HOME/.gem/ruby/*/bin $HOME/.gem/bin $HOME/Dropbox/bin $HOME/bin

# If not running interactively, don't do anything
# [ -z "$PS1" ] && exit

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
export HISTFILESIZE=100000000
export HISTSIZE=10000000

# platform specifics:
platform=`uname`

export CONDA_ROOT=$HOME/conda

test -f /etc/bash_completion && source /etc/bash_completion
# if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# if which kubectl > /dev/null; then
#   source <(kubectl completion bash)
# fi

if [ "$platform" = "Darwin" ] # I am a mac
    then
    export XML_CATALOG_FILES=/usr/local/etc/xml/catalog
    export XDG_DATA_HOME="$HOME/Library"
    export XDG_CONFIG_HOME="$HOME/Library"
    export XDG_CACHE_HOME="$HOME/Library/Caches"

    alias mate=nova
    alias tmate=$(which mate)
    # which -s subl && export EDITOR="subl -n -w"
    export EDITOR='nova -w'
    which -s trash && alias rm=trash

    # let's give atom a try:
    # which -s atom && export EDITOR="atom -w"
    # alias mate=atom
    # alias tmate=$(which mate)

    # bash completion from homebrew
    which -s brew && test -r "$(brew --prefix)/etc/bash_completion" &&  . "$(brew --prefix)/etc/bash_completion"
    export HOMEBREW_AUTO_UPDATE_SECS=86400  # 24 hours

    test -f $(which terraform 2>/dev/null) && complete -C $(which terraform) terraform

    # or fink:
    # testandrun /sw/bin/init.sh /sw/etc/bash_completion /opt/local/etc/bash_completion
    # or macports:
    # testandrun /opt/local/etc/bash_completion

    addPATH /usr/local/texlive/*/bin/universal-darwin
    # python:
    # addPATH $HOME/Library/Python/*/bin
    # addPATH /Applications/git-annex.app/Contents/MacOS
    # addPATH /opt/pypy/bin

    #EC2

else
    trash(){
        for f in $@; do
        mv -v "$@" $HOME/.Trash/
        done
    }

fi

# PS1='\u@$(tput setaf 1)\h$(tput sgr0):\w $(tput sgr0)$ '
#
# test -z "$SSH_CONNECTION" || PS1='\[$(tput sgr0)\]${debian_chroot:+($debian_chroot)}\[$(tput setaf 1)\]\u@\h\[$(tput sgr0)\][\A]\[$(tput sgr0)\]\w \[$(tput sgr0)\]$ '



# check for xserver, start one if none found
# if [ ! "`top -l 1 | grep -e 'X'`" ]
# then
#   startx &
# fi
# Python bins:
# addPATH /Library/Frameworks/Python.framework/Versions/*/bin
# addPATH $HOME/Library/Python/2.7/bin
# addPATH $HOME/Library/Python/3.4/bin
addPATH $CONDA_ROOT/bin
addPATH $HOME/usr/local/bin $HOME/.local/bin
addPATH $HOME/bin # make sure this is searched first
# echo $PATH
# setPYTHONPATH
# export PS1="\u@\w/: "




# Google SDK
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
GCLOUD=/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk
# export CLOUDSDK_PYTHON="$(brew --prefix)/opt/python@3.8/libexec/bin/python"
addPATH $GCLOUD/bin
testandrun $GCLOUD/path.bash.inc
testandrun $GCLOUD/completion.bash.inc

# fenics env
# export FENICS_PYTHON_EXECUTABLE=/usr/local/bin/python2
# export FENICS_SOURCE_BASE_PREFIX=$HOME/fenics-src
# export FENICS_INSTALL_BASE_PREFIX=$HOME/fenics

# virtualenvwrapper
export WORKON_HOME=$HOME/env
test -z "$(which virtualenvwrapper.sh)" || source "$(which virtualenvwrapper.sh)"

for f in $(brew --prefix)/etc/profile.d/*; do
  testandrun "$f"
done

test -z "$(which atuin)" || eval "$(atuin init bash --disable-up-arrow)"

export AUTOJUMP_AUTOCOMPLETE_CMDS='j'

test -z "$(which rbenv)" || eval "$(rbenv init -)"

# run this before we alias conda=mamba in aliases
export MAMBA_NO_BANNER=1
testandrun $HOME/conda/etc/profile.d/conda.sh
testandrun $HOME/conda/etc/profile.d/mamba.sh
testandrun $HOME/Dropbox/shell/functions
testandrun $HOME/Dropbox/shell/aliases

testandrun $HOME/dev/mine/git-stuff/bashrc
testandrun $HOME/btsync/shellrc

# wheels/eggs are zipfiles
# complete -f -X '!*.@(whl|egg|zip)' unzip zipinfo

export OMPI_MCA_rmaps_base_oversubscribe=1

export PYTEST_ADDOPTS="-v --ff"
