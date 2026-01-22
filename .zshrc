# Source secrets file (API keys, etc.) - not tracked in git
[[ -f ~/.secrets ]] && source ~/.secrets

# echo "Starting .zshrc"
# # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# # Initialization code that may require console input (password prompts, [y/n]
# # confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
# # If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$HOME/dacfx:/opt/homebrew/opt/avr-gcc@8/:$PATH
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export PATH="$PATH:/opt/nvim/"
export CPPFLAGS="-I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/v1/"

if [[ $(uname) == "Darwin" ]]; then
  export BROWSER="open -a Arc";
fi
if [ "$(uname -s)" = "Linux" ]; then
  export BROWSER="google-chrome";
fi

## ls coloring
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
alias ll="ls -alG"
# echo "Colors and alias done"
# # Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"
# export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
# # Set name of the theme to load --- if set to "random", it will
# # load a random theme each time oh-my-zsh is loaded, in which case,
# # to know which specific one was loaded, run: echo $RANDOM_THEME
# # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# # ZSH_THEME="robbyrussell"

# # Set list of themes to pick from when loading at random
# # Setting this variable when ZSH_THEME=random will cause zsh to load
# # a theme from this variable instead of looking in $ZSH/themes/
# # If set to an empty array, this variable will have no effect.
# # ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# # Uncomment the following line to use case-sensitive completion.
# # CASE_SENSITIVE="true"

# # Uncomment the following line to use hyphen-insensitive completion.
# # Case-sensitive completion must be off. _ and - will be interchangeable.
# # HYPHEN_INSENSITIVE="true"

# # Uncomment one of the following lines to change the auto-update behavior
# # zstyle ':omz:update' mode disabled  # disable automatic updates
# # zstyle ':omz:update' mode auto      # update automatically without asking
# # zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# # Uncomment the following line to change how often to auto-update (in days).
# # zstyle ':omz:update' frequency 13

# # Uncomment the following line if pasting URLs and other text is messed up.
# # DISABLE_MAGIC_FUNCTIONS="true"

# # Uncomment the following line to disable colors in ls.
# # DISABLE_LS_COLORS="true"

# # Uncomment the following line to disable auto-setting terminal title.
# # DISABLE_AUTO_TITLE="true"

# # Uncomment the following line to enable command auto-correction.
# # ENABLE_CORRECTION="true"

# # Uncomment the following line to display red dots whilst waiting for completion.
# # You can also set it to another string to have that shown instead of the default red dots.
# # e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# # Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# # COMPLETION_WAITING_DOTS="true"

# # Uncomment the following line if you want to disable marking untracked files
# # under VCS as dirty. This makes repository status check for large repositories
# # much, much faster.
# # DISABLE_UNTRACKED_FILES_DIRTY="true"

# # Uncomment the following line if you want to change the command execution time
# # stamp shown in the history command output.
# # You can set one of the optional three formats:
# # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# # or set a custom format using the strftime function format specifications,
# # see 'man strftime' for details.
# # HIST_STAMPS="mm/dd/yyyy"

# # Would you like to use another custom folder than $ZSH/custom?

# # Which plugins would you like to load?
# # Standard plugins can be found in $ZSH/plugins/
# # Custom plugins may be added to $ZSH_CUSTOM/plugins/
# # Example format: plugins=(rails git textmate ruby lighthouse)
# # Add wisely, as too many plugins slow down shell startup.
# plugins=(git)
# echo "added a git plugin"

# source $HOME/.oh-my-zsh/oh-my-zsh.sh
# echo "fpath update"

# # User configuration

# # export MANPATH="/usr/local/man:$MANPATH"

# # You may need to manually set your language environment
# # export LANG=en_US.UTF-8

# # Preferred editor for local and remote sessions
# # if [[ -n $SSH_CONNECTION ]]; then
# #   export EDITOR='vim'
# # else
# #   export EDITOR='mvim'
# # fi

# # Compilation flags
# # export ARCHFLAGS="-arch x86_64"

# # Set personal aliases, overriding those provided by oh-my-zsh libs,
# # plugins, and themes. Aliases can be placed here, though oh-my-zsh
# # users are encouraged to define aliases within the ZSH_CUSTOM folder.
# # For a full list of active aliases, run `alias`.
# #
# # Example aliases
# # alias zshconfig="mate ~/.zshrc"
# # alias ohmyzsh="mate ~/.oh-my-zsh"


# # Example Sources without oh-my-zsh, just they're still in the oh-my-zsh directory, but it's not enabled if you comment the source out up there ^^^
# source $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source $HOME/.oh-my-zsh/custom/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# source $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# echo "sourced zsh plugins"
export ZSH_CUSTOM=~/.zsh
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZSH_CUSTOM/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

alias js='~/.pscripts/journal-sync.sh'
alias ds='~/.pscripts/dotfiles-sync.sh'
alias ss='js; ds; newsboat -x reload; newsboat -x print-unread;'
# 
# Git aliases
alias gt='git tag'
alias gtpush='git push origin --tags'
alias gs='git status'
alias gcp='git cherry-pick'
alias ga='git add -A'
alias gc='git commit -m'
alias gac='git add -A && git commit -m'
alias gbranch='git branch'
alias gbranchd='git branch -D'
alias gcheck='git checkout'
alias gpull='git pull origin'
alias gpush='git push origin'

# yadm aliases
alias ys='yadm status'
alias ycp='yadm cherry-pick'
alias ya='yadm add'
alias yc='yadm commit -m'
alias yac='yadm add -u && yadm commit -m'
alias ybranch='yadm branch'
alias ybranchd='yadm branch -D'
alias ycheck='yadm checkout'
alias ycheckn='yadm checkout -b'
alias ypull='yadm pull origin'
alias ypush='yadm push origin'
alias ypushm='yadm push origin master'
alias ypullm='yadm push origin master'

# tmux aliases
alias ta='tmux attach -t'
alias tka='tmux kill-session -a && tmux kill-session'
alias tk='() {if [ "${TMUX+x}" ]; then tmux kill-session; fi}'
alias tn='tmux new -s'
###
alias ls='ls --color'
alias t='nvim'
alias t.='nvim .'

alias dockerclean='~/Development/scripts/dockerclean.sh'
alias myip="curl checkip.amazonaws.com"
alias nest="npx @nestjs/cli"
alias pip="pip3"
alias python="python3"
alias ghce="gh copilot explain"
alias ghcs="gh copilot suggest"
alias c="code"
alias y3="echo \"Setting yarn version to 3\" && pushd ~ 1>/dev/null && yarn set version 3 1>/dev/null && popd 1>/dev/null"
alias rf="rustfmt ./**/*.rs"


# export PNPM_HOME="$HOME/Library/pnpm"
# case ":$PATH:" in
#   *":$PNPM_HOME:"*) ;;
#   *) export PATH="$PNPM_HOME:$PATH" ;;
# esac
# # pnpm end

# # . /opt/homebrew/opt/asdf/libexec/asdf.sh
source ~/powerlevel10k/powerlevel10k.zsh-theme

# # # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$($HOME/.local/bin/mise activate zsh)"

# pnpm
export PNPM_HOME="/Users/andrewhessler/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/heffree/staging/google-cloud-sdk/path.zsh.inc' ]; then . '/home/heffree/staging/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/heffree/staging/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/heffree/staging/google-cloud-sdk/completion.zsh.inc'; fi

# opencode
export PATH=/Users/andrewhessler/.opencode/bin:$PATH

# opencode
export PATH=/home/heffree/.opencode/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/heffree/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/heffree/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/heffree/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/heffree/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# opencode
export PATH=/Users/Andrew.Hessler/.opencode/bin:$PATH
