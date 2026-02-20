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

# Agent config management - syncs AI tool configs across machines via agent repo
# Uses directory-based rules that work with Claude (.claude/rules/) and Cline (.clinerules/)
#
# Commands:
#   agent-bootstrap  - Initial setup: clone repo, link global configs, sync
#   agent-init       - Link current directory as a project

agent-bootstrap() {
  local changed=0

  # 1. Clone if ~/.agent doesn't exist
  if [[ ! -d ~/.agent/.git ]]; then
    echo "Cloning agent repo..."
    git clone git@github.com:deepakv158/agent.git ~/.agent || return 1
    changed=1
  fi

  # 2. Set up global rules directory
  mkdir -p ~/.agent/global/rules
  [[ ! -f ~/.agent/global/rules/main.md ]] && touch ~/.agent/global/rules/main.md

  # Claude global: ~/.claude/CLAUDE.md -> single file
  mkdir -p ~/.claude
  if [[ ! -L ~/.claude/CLAUDE.md || $(readlink ~/.claude/CLAUDE.md) != *".agent/global/rules/main.md" ]]; then
    ln -sf ~/.agent/global/rules/main.md ~/.claude/CLAUDE.md
    echo "Linked ~/.claude/CLAUDE.md -> global rules"
    changed=1
  fi

  # Cline global: ~/Documents/Cline/Rules/ -> directory
  mkdir -p ~/Documents/Cline
  if [[ ! -L ~/Documents/Cline/Rules || $(readlink ~/Documents/Cline/Rules) != *".agent/global/rules" ]]; then
    rm -rf ~/Documents/Cline/Rules 2>/dev/null
    ln -sf ~/.agent/global/rules ~/Documents/Cline/Rules
    echo "Linked ~/Documents/Cline/Rules -> global rules"
    changed=1
  fi

  # Codex global: ~/.codex/AGENTS.override.md -> single file
  mkdir -p ~/.codex
  if [[ ! -L ~/.codex/AGENTS.override.md || $(readlink ~/.codex/AGENTS.override.md) != *".agent/global/rules/main.md" ]]; then
    ln -sf ~/.agent/global/rules/main.md ~/.codex/AGENTS.override.md
    echo "Linked ~/.codex/AGENTS.override.md -> global rules"
    changed=1
  fi

  # 3. Sync with remote
  (
    cd ~/.agent
    git pull --rebase
    git add -A
    if ! git diff --cached --quiet; then
      git commit -m "sync $(date '+%Y-%m-%d %H:%M')"
      changed=1
    fi
    git push 2>/dev/null
  )

  [[ $changed -eq 0 ]] && echo "Already set up, nothing to do."
}

syncRepo(){
   # 3. Sync with remote
  (
    git pull --rebase
    git add -A
    if ! git diff --cached --quiet; then
      git commit -m "sync $(date '+%Y-%m-%d %H:%M')"
      changed=1
    fi
    git push 2>/dev/null
  )
}
agent-init() {
  # Ensure bootstrap has been run
  if [[ ! -d ~/.agent/.git ]]; then
    echo "Run agent-bootstrap first"
    return 1
  fi

  local project=$(basename $PWD)
  local rules_dir=~/.agent/projects/$project/rules
  mkdir -p "$rules_dir"
  [[ ! -f "$rules_dir/main.md" ]] && touch "$rules_dir/main.md"

  # Claude: .claude/rules/ -> directory
  mkdir -p .claude
  rm -rf .claude/rules 2>/dev/null
  ln -sf "$rules_dir" .claude/rules
  echo "Linked .claude/rules/"

  # Cline: .clinerules/ -> directory
  rm -rf .clinerules 2>/dev/null
  ln -sf "$rules_dir" .clinerules
  echo "Linked .clinerules/"

  # Codex: .codex/ -> directory
  rm -rf AGENTS.override.md 2>/dev/null
  ln -sf "$rules_dir/main.md" AGENTS.override.md
  echo "Linked codex rules"

  # Sync
  (
    cd ~/.agent
    syncRepo
  )

  echo "Initialized $project"
}

# Function to enable proxy settings (run after VPN connection)
enable_proxy() {
    export http_proxy="http://www-proxy-sjc.oraclecorp.com:80"
    export https_proxy="http://www-proxy-sjc.oraclecorp.com:80"
    export HTTP_PROXY="http://www-proxy-sjc.oraclecorp.com:80"
    export HTTPS_PROXY="http://www-proxy-sjc.oraclecorp.com:80"
    export proxy_rsync="http://www-proxy-sjc.oraclecorp.com:80"
    export PROXY_RSYNC="http://www-proxy-sjc.oraclecorp.com:80"
    export ftp_proxy="http://www-proxy-sjc.oraclecorp.com:80"
    export FTP_PROXY="http://www-proxy-sjc.oraclecorp.com:80"
    export all_proxy="http://www-proxy-sjc.oraclecorp.com:80"
    export ALL_PROXY="http://www-proxy-sjc.oraclecorp.com:80"
    export no_proxy="localhost,127.0.0.1,10.0.0.0/8,.oracle.com,.oraclecorp.com,.oraclevcn.com"
    export NO_PROXY="localhost,127.0.0.1,10.0.0.0/8,.oracle.com,.oraclecorp.com,.oraclevcn.com"
    echo "Proxy environment variables enabled."
}

# Function to disable proxy settings (run after VPN disconnect)
disable_proxy() {
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY \
          proxy_rsync PROXY_RSYNC ftp_proxy FTP_PROXY all_proxy ALL_PROXY \
          no_proxy NO_PROXY
    echo "Proxy environment variables cleared."
}
