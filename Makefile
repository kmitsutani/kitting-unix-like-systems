zsh_plugins := zsh-completions zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search

.PHONY: requirements tmux vim all install buildclean distclean allclean starship
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

all: tmux vim build/profile build/rc shell_plugins starship

clean: distclean buildclean

install: all
	ln -snf $(MAKEDIR)/build/vimrc $${HOME}/.vimrc
	ln -snf $(MAKEDIR)/build/vimrc_dein $${HOME}/.vimrc_dein
	ln -snf $(MAKEDIR)/build/vim $${HOME}/.vim
	ln -snf $(MAKEDIR)/build/tmux.conf $${HOME}/.tmux.conf
	ln -snf $(MAKEDIR)/build/tmux $${HOME}/.tmux
	ln -snf $(MAKEDIR)/build/rc $${HOME}/$(rc)
	ln -snf $(MAKEDIR)/build/profile $${HOME}/$(profile)
	ln -snf $(MAKEDIR)/build/starship.toml $${HOME}/.config/starship.toml

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

build/profile: dirs
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


build/rc: dirs
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

tmux: requirements dirs
	cp -r $(MAKEDIR)/src/tmux.conf $(MAKEDIR)/build/tmux.conf
	cp -r $(MAKEDIR)/src/tmux $(MAKEDIR)/build/tmux
	ln -snf $(MAKEDIR)/build/tmux.conf ~/.tmux.conf
	ln -snf $(MAKEDIR)/build/tmux ~/.tmux

vim: requirements dirs
	cp -r $(MAKEDIR)/src/vim $(MAKEDIR)/build/vim
	cp $(MAKEDIR)/src/vimrc $(MAKEDIR)/build/vimrc
	cp $(MAKEDIR)/src/vimrc_dein $(MAKEDIR)/build/vimrc_dein

libevent_version := 2.1.12
tmux_version := 3.3a
requirements: dirs
ifeq ($(shell which tmux 2>/dev/null | grep /.*tmux | wc -l), 0)
	mkdir -p $${HOME}/local/lib/pkgconfig

	git clone --depth=1 https://github.com/ThomasDickey/ncurses-snapshots.git $(MAKEDIR)/build/nurses
	cd $(MAKEDIR)/build/nurses
	./configure --prefix=~/local --with-shared --with-termlib --enable-pc-files \
		          --with-pkg-config-libdir=$${HOME}/local/lib/pkgconfig
	make && make install

	cd $(MAKEDIR)/build
	wget https://github.com/libevent/libevent/releases/download/release-$(libevent_version)-stable/libevent-$(libevent_version)-stable.tar.gz
	tar xzf libevent-$(libevent_version)-stable.tar.gz
	cd libevent-$(libevent_version)/
	./configure --prefix=$${HOME}/local --enable-shared
	make && make install

	cd $(MAKEDIR)/build
	wget https://github.com/tmux/tmux/releases/download/3.3a/tmux-$(tmux_version).tar.gz
	tar xzf tmux-$(tmux_version).tar.gz
	cd tmux-$(tmux_version)
	PKG_CONFIG_PATH=$${HOME}/local/lib/pkgconfig ./configure --prefix=$${HOME}/local
	make && make install
endif

starship: dirs
	cd $(MAKEDIR)/build
	curl https://starship.rs/install.sh -o starship-install.sh
	chmod +x starship-install.sh
	./starship-install.sh -b $${HOME}/.local/bin
	cp $(MAKEDIR)/src/starship.toml $(MAKEDIR)/build/starship.toml

dirs:
	mkdir build
	mkdir -p $${HOME}/.local/bin
	mkdir -p $${HOME}/.config
