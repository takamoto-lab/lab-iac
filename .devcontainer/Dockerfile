FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

RUN useradd -m -d /home/dev-user -s /bin/bash dev-user
USER dev-user

RUN git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv \
    && echo 'export PATH="${HOME}/.tfenv/bin:${PATH}"' >> ~/.bashrc \
    && . ~/.bashrc
