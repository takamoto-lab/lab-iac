ARG VARIANT=16-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

RUN \
    git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv \
    && echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile
