#!/usr/bin/env bash

# Check and install uv (Python package manager) if not present
if ! command -v uv &> /dev/null; then
  echo "uv not found, installing..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  # Ensure ~/.local/bin is in PATH for current and future sessions
  if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  fi
  export PATH="$HOME/.local/bin:$PATH"
else
  echo "uv is already installed."
fi

# Check and install nvm if not present
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  echo "nvm not found, installing..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  # Add nvm init to .bashrc and .bash_profile if not already present
  for profile in "$HOME/.bashrc"; do
    if ! grep -q 'export NVM_DIR="$HOME/.nvm"' "$profile"; then
      echo 'export NVM_DIR="$HOME/.nvm"' >> "$profile"
    fi
    if ! grep -q '\[ -s "\$NVM_DIR/nvm.sh" \] && \. "\$NVM_DIR/nvm.sh"' "$profile"; then
      echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$profile"
    fi
  done
  # Load nvm and install Node LTS
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
  nvm alias default 'lts/*'
else
  echo "nvm is already installed."
fi

# if bash_profile does not load bashrc, make sure it does
if [ -s "$HOME/.bash_profile" ]; then
    if ! grep -q 'source "$HOME/.bashrc"' "$HOME/.bash_profile"; then
        echo 'source "$HOME/.bashrc"' >> "$HOME/.bash_profile"
    fi
    else
       echo 'source "$HOME/.bashrc"' > "$HOME/.bash_profile"
fi
