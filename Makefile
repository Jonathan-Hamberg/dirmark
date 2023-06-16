COMMON_VIM_FLAGS:=-u NONE -U NONE -N  --cmd 'source plugin/dirmark.vim' --cmd 'set noswapfile' -S test/runner.vim test/test_dirmark.vim
EDITOR:=vim
SHELL:=bash


docker_build:
	docker build -t dirmark .

docker_test:
	 docker run -v $$(pwd):/app  -it dirmark make test_all

.PHONY: test
test:
	rm message.log || true
	$(EDITOR) --cmd 'set shell=$(SHELL)' $(COMMON_VIM_FLAGS)
	grep "0 errors, 0 failures" messages.log

test_all:
	$(MAKE) EDITOR=vim SHELL=fish test
	$(MAKE) EDITOR=vim SHELL=bash test
	$(MAKE) EDITOR=vim SHELL=zsh test
	$(MAKE) EDITOR=vim SHELL=ash test
	$(MAKE) EDITOR=nvim SHELL=fish test
	$(MAKE) EDITOR=nvim SHELL=bash test
	$(MAKE) EDITOR=nvim SHELL=zsh test
	$(MAKE) EDITOR=nvim SHELL=ash test

editor:
	$(EDITOR) -u NONE -U NONE -N  --cmd 'source plugin/dirmark.vim'
