# treehouse — spin up a git worktree + tmux window + Claude Code agent
#
# Usage:
#   treehouse <branch> [base]   create worktree + tmux window + agent pane
#   treehouse-rm <branch>       tear down worktree + close tmux window
#   treehouse-ls                list active worktrees for the current repo

treehouse() {
  local branch="${1:?Usage: treehouse <branch> [base-branch]}"
  local base="${2:-main}"
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "treehouse: not in a git repo" >&2; return 1
  }

  local repo_name window_name worktree_dir
  repo_name=$(basename "$repo_root")
  # sanitize branch for tmux window name (replace / with -)
  window_name="${repo_name}:${branch//\//-}"
  worktree_dir="${repo_root}/../${repo_name}-${branch//\//-}"

  [[ -z "$TMUX" ]] && { echo "treehouse: must be run inside tmux" >&2; return 1; }

  # Create branch if it doesn't exist
  if ! git -C "$repo_root" show-ref --verify --quiet "refs/heads/${branch}"; then
    git -C "$repo_root" branch "$branch" "$base" || return 1
    echo "treehouse: created branch ${branch} from ${base}"
  fi

  # Create worktree if it doesn't exist
  if [[ ! -d "$worktree_dir" ]]; then
    git -C "$repo_root" worktree add "$worktree_dir" "$branch" || return 1
  fi

  # If window already exists, just switch to it
  if tmux list-windows -F '#{window_name}' | grep -qx "$window_name"; then
    tmux select-window -t "$window_name"
    echo "treehouse: switched to existing window ${window_name}"
    return 0
  fi

  # New window: left pane = editor (nvim), right pane = Claude Code agent
  tmux new-window -n "$window_name" -c "$worktree_dir"
  tmux split-window -h -p 40 -c "$worktree_dir"
  tmux send-keys "claude" Enter
  tmux select-pane -L   # focus left (editor) pane

  echo "treehouse: opened ${window_name} at ${worktree_dir}"
}

treehouse-rm() {
  local branch="${1:?Usage: treehouse-rm <branch>}"
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "treehouse-rm: not in a git repo" >&2; return 1
  }

  local repo_name window_name worktree_dir
  repo_name=$(basename "$repo_root")
  window_name="${repo_name}:${branch//\//-}"
  worktree_dir="${repo_root}/../${repo_name}-${branch//\//-}"

  # Close tmux window
  if [[ -n "$TMUX" ]] && tmux list-windows -F '#{window_name}' | grep -qx "$window_name"; then
    tmux kill-window -t "$window_name" && echo "treehouse-rm: closed window ${window_name}"
  fi

  # Remove worktree
  if [[ -d "$worktree_dir" ]]; then
    git -C "$repo_root" worktree remove --force "$worktree_dir" && \
      echo "treehouse-rm: removed worktree ${worktree_dir}"
  fi
}

treehouse-ls() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "treehouse-ls: not in a git repo" >&2; return 1
  }
  git -C "$repo_root" worktree list
}
