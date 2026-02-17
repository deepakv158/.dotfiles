# Path to your dotfiles.
export DOTFILES=$HOME/.dotfiles

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation   .
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

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
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$DOTFILES

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Add rancher desktop path

#export PATH="/Users/deviswan/.rd/bin/:$PATH"
#export PATH="/Users/deviswan/.rd/bin/:$PATH"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

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

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
#export PATH="/Users/deviswan/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
#export PATH="$PATH:$HOME/.rvm/bin"

export JAVA_HOME="/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
export PATH=$JAVA_HOME/bin:$PATH
export PATH="$PATH:$HOME/.local/bin"



# Load secret environment variables
if [[ -f "$HOME/.secrets" ]]; then source "$HOME/.secrets"; fi

# Agent config management - syncs CLAUDE.md, .clinerules across machines via dotfiles repo

# One-time setup on a new machine
agent-setup() {
  local agent_path="$DOTFILES/agent"

  # Check if agent folder exists in dotfiles
  if [[ ! -d "$agent_path" ]]; then
    echo "Error: agent folder not found in dotfiles at:"
    echo "  $agent_path"
    echo "Make sure dotfiles repo is cloned and has agent/ directory."
    return 1
  fi

  # Create ~/.claude if needed
  mkdir -p ~/.claude

  # Symlink ~/.agent to dotfiles (force update if pointing elsewhere)
  if [[ -e ~/.agent && ! -L ~/.agent ]]; then
    echo "Error: ~/.agent exists and is not a symlink. Remove it first."
    return 1
  else
    ln -sfn "$agent_path" ~/.agent
    echo "Linked ~/.agent -> $agent_path"
  fi

  # Symlink global CLAUDE.md (force update if pointing elsewhere)
  if [[ -e ~/.claude/CLAUDE.md && ! -L ~/.claude/CLAUDE.md ]]; then
    echo "Warning: ~/.claude/CLAUDE.md is a real file. Back it up and remove to link."
  else
    ln -sf ~/.agent/global/CLAUDE.md ~/.claude/CLAUDE.md
    echo "Linked ~/.claude/CLAUDE.md -> ~/.agent/global/CLAUDE.md"
  fi

  echo "Done. Run 'agent-init' in any project to link project configs."
}

# Per-project setup
agent-init() {
  local project=$(basename $PWD)
  local agent_dir=~/.agent/projects/$project

  # Create project folder and empty configs if needed
  mkdir -p "$agent_dir"
  [[ ! -f "$agent_dir/CLAUDE.md" ]] && touch "$agent_dir/CLAUDE.md"
  [[ ! -f "$agent_dir/.clinerules" ]] && touch "$agent_dir/.clinerules"

  # Symlink into project (-sf replaces existing)
  ln -sf "$agent_dir/CLAUDE.md" ./CLAUDE.md
  ln -sf "$agent_dir/.clinerules" ./.clinerules

  echo "Linked to ~/.agent/projects/$project/"
}
