FROM codercom/enterprise-base:ubuntu

# Install dependencies for NVM, Node, uv, Android tools, and zsh
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    unzip \
    openjdk-21-jdk \
    python3-pip \
    python3-venv \
    git \
    ca-certificates \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Install Minikube
RUN curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
    install minikube-linux-amd64 /usr/local/bin/minikube && \
    rm minikube-linux-amd64

# Set zsh as default shell for coder user
USER root
RUN chsh -s /usr/bin/zsh coder

# Install oh-my-zsh and configure Rust environment
USER coder
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    echo 'source $HOME/.cargo/env' >> ~/.zshrc

# Install and configure powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc && \
    echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> ~/.zshrc
ENV PATH="/home/coder/.cargo/bin:$PATH"
ENV SHELL=/usr/bin/zsh

# Create .bashrc and .bash_profile for user coder

ENV NVM_DIR=/home/coder/.nvm
ENV PATH="$HOME/.local/bin:$PATH"

# Install Android command-line tools
USER root

ADD startup.sh /opt/coder/startup.sh
RUN chmod +x /opt/coder/startup.sh && \
    ln -s /opt/coder/startup.sh /usr/local/bin/coder-startup

ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="$PATH:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/emulator"
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    cd /tmp && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip && \
    rm cmdline-tools.zip && \
    mv cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT --licenses && \
    $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT \
        "platform-tools" \
        "platforms;android-34" \
        "build-tools;34.0.0" \
        "emulator" \
        "cmdline-tools;latest"

# Set permissions for coder user
RUN chown -R coder:coder $ANDROID_SDK_ROOT

USER coder
ENV PATH="$PATH:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/emulator"
