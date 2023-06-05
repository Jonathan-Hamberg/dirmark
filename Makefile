COMMON_VIM_FLAGS:=-u NONE -U NONE -N  --cmd 'set shellcmdflag=-ic' --cmd 'source plugin/dirmark.vim' -S test/runner.vim test/test_dirmark.vim
EDITOR:=vim
SHELL:=bash


docker_build:
	docker build -t dirmark .

docker_test:
	 docker run -v $$(pwd):/app  -it dirmark make test

.PHONY: test
test:
	env TO_DIR=tmp/tofish SDIRS=tmp/bashmarks $(EDITOR) --cmd 'set shell=$(SHELL)' $(COMMON_VIM_FLAGS)
	cat messages.log
	rm messages.log

editor:
	$(EDITOR) -u NONE -U NONE -N  --cmd 'source plugin/dirmark.vim'
