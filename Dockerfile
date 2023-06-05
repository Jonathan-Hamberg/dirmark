FROM alpine:3.14
RUN apk add --no-cache bash fish git make vim neovim zsh
RUN mkdir -p ~/.config/fish/conf.d ~/.config/fish/functions ~/.config/fish/completions
RUN git clone https://github.com/huyng/bashmarks.git && make -C bashmarks install
RUN git clone https://github.com/joehillen/to-fish.git && make -C to-fish
RUN echo "source ~/.local/bin/bashmarks.sh" > ~/.bashrc
RUN echo "source ~/.local/bin/bashmarks.sh" > ~/.zshrc
WORKDIR /app
