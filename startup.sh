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

# Install oh-my-zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "oh-my-zsh not found, installing..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "oh-my-zsh is already installed."
fi

# Install powerlevel10k theme if not present
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "powerlevel10k theme not found, installing..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  # Configure powerlevel10k theme in .zshrc
  if [ -f "$HOME/.zshrc" ]; then
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
    if ! grep -q 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' "$HOME/.zshrc"; then
      echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> "$HOME/.zshrc"
    fi
  fi
else
  echo "powerlevel10k theme is already installed."
fi

# Install Rust if not present
if ! command -v rustc &> /dev/null; then
  if [ -f "$HOME/.cargo/env" ]; then
    echo "Rust found but not in PATH, sourcing environment..."
    source "$HOME/.cargo/env"
  else
    echo "Rust not found, installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
    # Add Rust to shell profiles for persistence
    if [ -f "$HOME/.bashrc" ] && ! grep -q 'source $HOME/.cargo/env' "$HOME/.bashrc"; then
      echo 'source $HOME/.cargo/env' >> "$HOME/.bashrc"
    fi
    if [ -f "$HOME/.zshrc" ] && ! grep -q 'source $HOME/.cargo/env' "$HOME/.zshrc"; then
      echo 'source $HOME/.cargo/env' >> "$HOME/.zshrc"
    fi
    # Source for current session
    source "$HOME/.cargo/env"
  fi
else
  echo "Rust is already installed."
fi
