FROM alpine
RUN apk add --no-cache bash fish zsh make vim neovim
WORKDIR /app
