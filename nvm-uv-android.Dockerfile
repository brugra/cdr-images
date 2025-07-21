FROM codercom/enterprise-base:ubuntu

# Install dependencies for NVM, Node, uv, and Android tools
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
    && rm -rf /var/lib/apt/lists/*

# Create .bashrc and .bash_profile for user coder
USER coder
RUN touch /home/coder/.bashrc /home/coder/.bash_profile && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> /home/coder/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/coder/.bashrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> /home/coder/.bash_profile && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/coder/.bash_profile

# Install NVM and Node LTS for user coder
ENV NVM_DIR=/home/coder/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install --lts && \
    nvm use --lts && \
    nvm alias default 'lts/*'

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Android command-line tools
USER root
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
