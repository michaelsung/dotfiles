export PATH="$HOME/.local/bin:$PATH"

# load version control information
autoload -Uz vcs_info
precmd() {
  vcs_info
  git_sync_status=''
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local ahead behind
    ahead=$(git rev-list @{u}..HEAD --count 2>/dev/null)
    behind=$(git rev-list HEAD..@{u} --count 2>/dev/null)
    if [[ -n "$ahead" && -n "$behind" && "$ahead" -eq 0 && "$behind" -eq 0 ]]; then
      git_sync_status="%F{green}✓%f"
    else
      [[ -n "$ahead"  && "$ahead"  -gt 0 ]] && git_sync_status+="%F{cyan}↑${ahead}%f"
      [[ -n "$behind" && "$behind" -gt 0 ]] && git_sync_status+="%F{red}↓${behind}%f"
    fi
  fi
}

# format vcs_info variable
zstyle ':vcs_info:git:*' formats ' / %F{green}%b%f'

# set up the prompt
setopt PROMPT_SUBST
PROMPT='%F{yellow}%m%f / %F{blue}%~%f${vcs_info_msg_0_}${git_sync_status:+ }${git_sync_status} $ '

# Claude Code safety-net
export SAFETY_NET_STRICT=1        # Fail-closed on unparseable commands
export SAFETY_NET_PARANOID_RM=1   # Block rm -rf anywhere, not just outside cwd

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# claude-docker testing
export PATH="$HOME/projects/claude-docker:$PATH"
