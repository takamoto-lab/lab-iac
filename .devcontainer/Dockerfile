ARG VARIANT=16-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:0-${VARIANT}

# ./aws setup
RUN cd aws && \
    npm install && \
    poetry install
