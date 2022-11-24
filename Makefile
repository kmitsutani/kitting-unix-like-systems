zsh_plugins := zsh-completions zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search

.PHONY: requirements tmux vim all install buildclean distclean allclean
.DEFAULT_GOAL := all

MAKEDIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SHELLBIN:=$(notdir $(shell echo $$SHELL))
ifeq ($(SHELLBIN), bash)
	rc := .bashrc
	profile := .bash_profile
else ifeq ($(SHELLBIN), zsh)
	rc := .zshrc
	profile := .zprofile
endif

ifeq ($(shell uname), Linux)
ifneq ($(shell which apt-get 2>/dev/null | wc -l), 0)
	install_pkg := sudo apt-get install
else ifneq ($(shell which pacman 2>/dev/null | wc -l), 0)
	install_pkg := sudo pacman -S
endif
else ifeq ($(shell uname), Darwin)
	install_pkg := /opt/homebrew/bin/brew install
endif

all: tmux vim build/profile build/rc shell_plugins

clean: distclean buildclean

install: all
	ln -snf $(MAKEDIR)/build/vimrc ~/.vimrc
	ln -snf $(MAKEDIR)/build/vimrc_dein ~/.vimrc_dein
	ln -snf $(MAKEDIR)/build/vim ~/.vim
	ln -snf $(MAKEDIR)/build/tmux.conf ~/.tmux.conf
	ln -snf $(MAKEDIR)/build/tmux ~/.tmux
	ln -snf $(MAKEDIR)/build/rc ~/$(rc)
	ln -snf $(MAKEDIR)/build/profile ~/$(profile)

distclean:
	rm ~/.vimrc ~/.vimrc_dein ~/.tmux.conf ~/.tmux ~/$(rc) ~/$(profile)
	for plugin in $(zsh_plugins); do\
		rm -rf ~/.zsh/plugins/$$plugin;\
	done

buildclean:
	rm -rf build/*

shell_plugins: 
ifeq ($(SHELLBIN), zsh)
	mkdir -p ~/.zsh/plugins
	for plugin in $(zsh_plugins); do\
		git clone --depth=1 https://github.com/zsh-users/$$plugin.git ~/.zsh/plugins/$$plugin;\
	done
endif

build/profile: build
ifeq ($(SHELLBIN), bash)
	cat src/bash_profile_header >> $@
	cat src/export_envs >> $@
	cat src/export_path >> $@
ifeq ($(shell uname), Darwin)
	/opt/homebrew/bin/brew shellenv >> $@
endif
	cat src/ssh_common >> $@
	cat src/ssh_profile >> $@
	cat src/bash_profile_footer >> $@
else ifeq ($(SHELLBIN), zsh)
	cat src/zprofile_header >> $@
	cat src/export_envs >> $@
	cat src/export_path >> $@
ifeq ($(shell uname), Darwin)
	/opt/homebrew/bin/brew shellenv >> $@
endif
	cat src/ssh_common >> $@
	cat src/ssh_profile >> $@
	cat src/zprofile_footer >>  $@
endif


build/rc: build
ifeq ($(SHELLBIN), bash)
	cat src/bashrc_header >> $@
	cat src/ssh_common >> $@
	cat src/sshrc >> $@
	cat src/bashrc_footer >> $@
else ifeq ($(SHELLBIN), zsh)
	cat src/zshrc_header >> $@
	cat src/ssh_common >> $@
	cat src/sshrc >> $@
	cat src/zshrc_footer >> $@
endif

tmux: requirements build
	cp -r $(MAKEDIR)/src/tmux.conf $(MAKEDIR)/build/tmux.conf
	cp -r $(MAKEDIR)/src/tmux $(MAKEDIR)/build/tmux
	ln -snf $(MAKEDIR)/build/tmux.conf ~/.tmux.conf
	ln -snf $(MAKEDIR)/build/tmux ~/.tmux

vim: requirements build
	cp -r $(MAKEDIR)/src/vim $(MAKEDIR)/build/vim
	cp $(MAKEDIR)/src/vimrc $(MAKEDIR)/build/vimrc
	cp $(MAKEDIR)/src/vimrc_dein $(MAKEDIR)/build/vimrc_dein

requirements:
ifeq ($(shell which tmux 2>/dev/null | grep /.*tmux | wc -l), 0)
	$(install_pkg) tmux
endif
ifeq ($(shell which bc 2>/dev/null | grep /.*bc | wc -l), 0)
	$(install_pkg) bc
endif
ifeq ($(shell which w3m 2>/dev/null | grep /.*w3m | wc -l), 0)
	$(install_pkg) w3m
endif

build:
	mkdir build
