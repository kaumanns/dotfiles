#
# Configuration
#
# Options:
#
# - setup-recipe
# - package-dependencies
# - pip-dependencies
# - required-directories
# - prerequisites
# - order-only-prerequisites

################################################################################
# Custom targets (overrides generic stow)

base: $(addsuffix .stow,zsh mutt vim ranger dircolors i3 X st tmux)

firefox.stow: firefox
	$(call stow,$(wildcard $(HOME)/.mozilla/firefox/*.default-release/),$<)

################################################################################
# vim

vim.package-dependencies = neovim $(vim.youcompleteme.package-dependencies)
vim.youcompleteme.package-dependencies := cmake python3-dev build-essential
vim.pip-dependencies := neovim

define vim.setup-recipe
cd $(HOME)/.vim/pack/plugins/start/YouCompleteMe \
	&& ./install.py --clang-completer;
endef

################################################################################\
# mutt

mutt.package-dependencies := neomutt maildir-utils msmtp notmuch notmuch-mutt urlscan isync feh
mutt.required-directories := $(HOME)/.mail/personal $(HOME)/.mail/work

define mutt.setup-recipe
mbsync --all;
mu index --maildir $(HOME)/.mail;
echo "Don't forget to export EMAIL=<user@host.tld>!";
endef

################################################################################
# zsh

zsh.package-dependencies = zsh w3m w3m-img unzip pass htop ncdu rsync highlight autossh $(pandoc.package-dependencies)
zsh.order-only-prerequisites := dircolors.stow

define zsh.setup-recipe
$(GIT) config --global user.email "$$USER@`hostname`" \
	&& $(GIT) config --global user.name "$$USER";
[[ -e $(HOME)/.ssh/id_rsa.pub ]] \
	|| ssh-keygen \
		-t rsa \
		-b 4096 \
		-C "`whoami`@`hostname`";
endef

################################################################################
# st

st.package-dependencies := libfreetype-dev libx11-dev libxft-dev
st.diffs := st-my.diff st-no_bold_colors-20170623-b331da5.diff st-solarized-dark-20180411-041912a.diff st-scrollback-20200419-72e3f6c.diff st-scrollback-mouse-20191024-a2c479c.diff st-scrollback-mouse-altscreen-20200416-5703aa0.diff st-hidecursor-0.8.3.diff st-w3m-0.8.3.diff

define st.setup-recipe
cd $(HOME)/.config/st/st \
	&& $(GIT) reset --hard \
	&& $(GIT) pull && make clean \
	&& rm -rf config.h \
	$(foreach diff,$(st.diffs),&& echo "Applying patch: $(diff)" && patch -Np1 -i ../$(diff)) \
	&& sudo make clean install;
endef

################################################################################\
# fonts

fonts.package-dependencies := fontconfig fonts-font-awesome
fonts.setup-recipe = fc-cache -v -f;

################################################################################
# Misc

X.package-dependencies := rxvt-unicode

i3.package-dependencies := i3 xorg rxvt-unicode blueman pasystray pavucontrol scrot

pandoc.package-dependencies := pandoc pandoc-citeproc texlive-xetex texlive-lang-german

ranger.package-dependencies := ranger

system.package-dependencies := firefox

tmux.package-dependencies := tmux

dircolors.pip-dependencies := dircolors
