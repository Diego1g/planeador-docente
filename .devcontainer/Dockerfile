FROM mcr.microsoft.com/devcontainers/javascript-node

# Install Graphviz for dot command
RUN apt-get update && \
    apt-get install -y graphviz chromium && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Marp CLI globally
RUN npm install -g @marp-team/marp-cli

# Set working directory
WORKDIR /workspace
