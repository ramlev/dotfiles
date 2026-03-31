# All the dig info
function digga() {
	dig +nocmd "$1" any +multiline +noall +answer
}

function removehost() {
   ssh-keygen -R "$1"
}
function __git_prompt_git() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}
function git_current_branch() {
  local ref
  ref=$(__git_prompt_git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude .git . "$1" 2>/dev/null
}

#  Commit everything
function commit() {
  commitMessage="$*"

  if gum confirm "Execute git add . ?" --default=No; then
    git add .
  else
    selected=$({ git diff --name-only; git ls-files --others --exclude-standard; } | sort -u | gum choose --no-limit --header "Select files to stage:")
    if [ -n "$selected" ]; then
      echo "$selected" | xargs git add
    fi
  fi

  # Exit if nothing is staged
  if git diff --cached --quiet; then
    gum style --foreground 196 "Nothing staged. Aborting."
    return 1
  fi

  if [ "$commitMessage" = "" ]; then
    # Show diff stats in a styled format
    gum style --border rounded --padding "1 2" --margin "1 0" \
      "$(git diff --cached --stat)"

    # Get diff for AI processing
    diff_input=$(echo "=== Summary ===" && git diff --cached --stat && \
                 echo -e "\n=== Diff (truncated if large) ===" && \
                 git diff --cached | head -c 50000)

    # Generate commit message with spinner
    commitMessage=$(echo "$diff_input" | gum spin --spinner dot \
      --title "Generating commit message..." -- \
      claude -p "Write a single-line commit message for this diff. Output ONLY the message, no quotes, no explanation, no markdown.")

    # Show generated message and confirm
    gum style --foreground 212 --bold "Generated message:"
    gum style --foreground 86 --italic "$commitMessage"

    if gum confirm "Use this commit message?"; then
      git commit -m "$commitMessage"
      gum style --foreground 46 "✓ Committed successfully!"
    else
      # Allow editing
      commitMessage=$(gum input --placeholder "Enter commit message..." --value "$commitMessage")
      git commit -m "$commitMessage"
      gum style --foreground 46 "✓ Committed successfully!"
    fi
    return
  fi

  # Manual commit message provided
  eval "git commit -a -m '${commitMessage}'"
  gum style --foreground 46 "✓ Committed successfully!"
}

function claude-yolo() {
  claude --dangerously-skip-permissions "$@"
}

function git-prune-local() {
  git fetch -p && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D
}

function clone() {
  gh repo clone "$1" "${@:2}"
}

function mkcd() {
  mkdir -p "$@" && cd "$@"
}
