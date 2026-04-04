export PATH="$HOME/.local/bin:$PATH"

# load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# format vcs_info variable
zstyle ':vcs_info:git:*' formats ':%F{green}%b%f'

# set up the prompt
setopt PROMPT_SUBST
PROMPT='%F{yellow}%m%f:%F{blue}%~%f${vcs_info_msg_0_} $ '

# Claude Code safety-net
export SAFETY_NET_STRICT=1        # Fail-closed on unparseable commands
export SAFETY_NET_PARANOID_RM=1   # Block rm -rf anywhere, not just outside cwd

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
