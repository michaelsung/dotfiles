export PATH="$HOME/.local/bin:$PATH"

# Claude Code safety-net
export SAFETY_NET_STRICT=1        # Fail-closed on unparseable commands
export SAFETY_NET_PARANOID_RM=1   # Block rm -rf anywhere, not just outside cwd

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
