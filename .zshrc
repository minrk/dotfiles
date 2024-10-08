# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="candy"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# autocorrect is wrong way more often than it's right
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes
# non-legacy completion doesn't complete images or containers
zstyle ':omz:plugins:docker' legacy-completion yes

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(brew git github docker docker-compose 1password terraform autojump kubectl gcloud pip)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='rmate'
else
  export EDITOR='nova -w'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# add to PATH
# typeset -U makes path unique
typeset -U path PATH
function addPATH() {
  # adds a path to front of $PATH if it exists,
  # otherwise do nothing
  # typeset -U above ensures it is unique
  if [[ -d "$1" ]]; then
    path=("$1" "$path[@]")
  fi
}
addPATH /opt/homebrew/bin

function testandrun () {
  # source a file if it exists (e.g. various rc files)
  test -f "$1" && source "$1"
}

export CONDA_ROOT=$HOME/conda
addPATH $CONDA_ROOT/bin

addPATH ${KREW_ROOT:-$HOME/.krew}/bin

# run this before we alias conda=mamba! in aliases
export MAMBA_NO_BANNER=1

testandrun $CONDA_ROOT/etc/profile.d/conda.sh
testandrun $CONDA_ROOT/etc/profile.d/mamba.sh

_dotfiles=$(dirname $(readlink $(print -P %N)))
. ${_dotfiles}/aliases
. ${_dotfiles}/functions

addPATH ${_dotfiles}/bin

platform=$(uname)
if [ "$platform" = "Darwin" ]; then # I am a mac
  testandrun "${HOME}/.iterm2_shell_integration.zsh"
  whichs trash && alias rm=trash
  export XDG_DATA_HOME="$HOME/Library"
  export XDG_CONFIG_HOME="$HOME/Library"
  export XDG_CACHE_HOME="$HOME/Library/Caches"
  
  # my fingers will never stop typing 'mate'
  alias mate=nova
  alias tmate=$(which mate)

  # which -s brew && test -r "$(brew --prefix)/etc/bash_completion" &&  . "$(brew --prefix)/etc/bash_completion"
  export HOMEBREW_AUTO_UPDATE_SECS=86400  # 24 hours

fi

gitstuff=$HOME/dev/mine/git-stuff
addPATH $gitstuff/bin
testandrun $gitstuff/aliases
testandrun $gitstuff/kubernetes.bashrc

export PYTEST_ADDOPTS="-v --ff"

addPATH ${HOME}/.local/bin
addPATH ${HOME}/bin

# testandrun /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# testandrun /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc

whichs atuin && eval "$(atuin init zsh --disable-up-arrow)"

# seems to mess up completion on aliases
unsetopt completealiases

export PS1='%{$fg_bold[green]%}%n@%m %{$fg[blue]%}%D{[%X]} %{$reset_color%}%(5~|%-1~/…/%50<…<%3~%<<|%50<…<%~%<<)%{$reset_color%} $(git_prompt_info)
%{$fg_bold[blue]%}> %{$reset_color%}'

whichs virtualenvwrapper.sh && source virtualenvwrapper.sh
