#
# Configuration
#

################################################################################
# i3

i3.target = $(HOME)/.config/i3/config

i3.package-dependencies = \
	$(i3.battery_management) \
	$(i3.command_line_applications) \
	$(i3.desktop_applications) \
	$(i3.printer) \
	$(i3.wireless) \
	$(i3.fonts)

i3.android_file_transfer = libmtp gvfs-mtp
i3.audio = cmus tageditor
i3.video = mpv
i3.battery_management = tlp tp_smapi
i3.bluetooth = blueman bluez buez-utils
i3.command_line_applications = pulseaudio-bluetooth autorandr openssh wget zbar pdftk $(i3.audio)
i3.desktop_applications = dmenu xreader cheese redshift gpicview pwgen $(i3.file_manager) $(i3.video)
i3.file_manager = thunar gvfs thunar-archive-plugin file-roller udiskie $(i3.android_file_transfer)
i3.network-manager = network-manager network-manager-applet
i3.printer = cups avahi-daemon nss-mdns
i3.wireless = $(i3.bluetooth) $(i3.network-manager)
i3.fonts = noto-fonts-emoji

i3.systemd_services = bluetooth networkmanager tlp sshd avahi-daemon
i3.systemd_sockets = cups

define i3.systemctl_enable_start =
sudo systemctl enable $(1);
sudo systemctl start $(1);
endef

define i3.systemctl_enable =
sudo systemctl enable $(1);
endef

define i3.setup-recipe
modprobe btusb;
$(foreach unit,$(i3.systemd_services),$(call i3.systemctl_enable_start,$(unit)))
$(foreach unit,$(i3.systemd_sockets),$(call i3.systemctl_enable,$(unit)))
endef

################################################################################
# vim

vim.target := $(HOME)/.vimrc

vim.package-dependencies := neovim $(vim.youcompleteme.package-dependencies)
vim.youcompleteme.package-dependencies := cmake python3
vim.pip-dependencies := neovim yamllint

# define vim.setup-recipe
define vim.setup-recipe
cd $(HOME)/.vim/pack/plugins/start/YouCompleteMe \
	&& ./install.py \
		--clang-completer \
		--system-libclang;
endef

################################################################################
# Firefox

firefox.target =  $(HOME).mozilla/user-overrides.js

firefox.package-dependencies = firefox

# Update hardened user.js from repo and apply user overrides.
define firefox.setup-recipe
$(HOME)/.mozilla/user.js/updater.sh \
	-s \
	-o $(HOME)/.mozilla/user-overrides.js \
	-p $(HOME)/.mozilla/firefox/*default-release
endef

################################################################################\
# mutt

mutt.target = $(HOME)/.muttrc

mutt.package-dependencies := neomutt msmtp notmuch notmuch-mutt urlscan isync feh pass

define mutt.setup-recipe
mkdir -p $(HOME)/Mail/personal $(HOME)/Mail/work
mbsync --all;
notmuch new;
mu init --maildir $(HOME)/.mail && mu index;
echo "Don't forget to export EMAIL=<USER@HOST.TLD>!";
endef

################################################################################
# zsh

# zsh.package-dependencies = zsh w3m unzip pass htop ncdu rsync highlight autossh imagemagick tlp tlp-rdw $(zsh.pandoc.package-dependencies)
# zsh.pandoc.package-dependencies := pandoc texlive-most inetutils
# zsh.order-only-prerequisites := dircolors.stow
#
# define zsh.setup-recipe
# echo "Setting up git" \
# 	&& $(GIT) config --global user.email "$$USER@`hostname`" \
# 	&& $(GIT) config --global user.name "$$USER" \
# 	&& $(GIT) config --global pull.rebase false;
# chsh -s /bin/zsh $$USER;
# echo "Setting up ssh" \
#   && [[ -e $(HOME)/.ssh/id_rsa.pub ]] \
# 		|| ssh-keygen \
# 			-t rsa \
# 			-b 4096 \
# 			-C "`whoami`@`hostname`";
# endef

zsh.target = $(HOME)/.zshrc
dircolors.target = $(HOME)/.dircolors

zsh.package-dependencies = zsh w3m unzip pass htop ncdu rsync highlight autossh imagemagick tlp tlp-rdw $(zsh.pandoc.package-dependencies)
zsh.pandoc.package-dependencies := pandoc texlive-most inetutils
zsh.prerequisites := $(dircolors.target)

define zsh.setup-recipe
echo "Setting up git" \
	&& $(GIT) config --global user.email "$$USER@`hostname`" \
	&& $(GIT) config --global user.name "$$USER" \
	&& $(GIT) config --global pull.rebase false;
chsh -s /bin/zsh $$USER;
echo "Setting up ssh" \
  && [[ -e $(HOME)/.ssh/id_rsa.pub ]] \
		|| ssh-keygen \
			-t rsa \
			-b 4096 \
			-C "`whoami`@`hostname`";
endef

################################################################################
# st

st.target = $(HOME)/.config/st/st-my.diff

st.package-dependencies := libfreetype-dev libx11-dev libxft-dev fonts-symbola
st.diffs := \
  st-my.diff \
  st-no_bold_colors-20170623-b331da5.diff \
  st-solarized-dark-20180411-041912a.diff \
  st-hidecursor-0.8.3.diff \
  st-w3m-0.8.3.diff \
  st-scrollback-20210507-4536f46.diff \
  st-scrollback-mouse-20191024-a2c479c.diff \
  st-scrollback-mouse-altscreen-20200416-5703aa0.diff

define st.setup-recipe
cd $(HOME)/.config/st/st \
	&& $(GIT) checkout master \
	&& $(GIT) reset --hard \
	&& $(GIT) pull && make clean \
	&& rm -rf config.h \
	$(foreach diff,$(st.diffs),&& echo "Applying patch: $(diff)" && patch -Np1 -i ../$(diff)) \
	&& sudo make clean install;
endef

################################################################################
# neomutt TODO

neomutt.package-dependencies :=

define neomutt.setup-recipe
sudo apt build-dep neomutt
export EXTRA_LDFLAGS="-lssl -lcrypto" \
  && ./configure \
		--ssl \
		--build=x86_64-linux-gnu --prefix=/usr {--includedir=${prefix}/include} {--mandir=${prefix}/share/man} {--infodir=${prefix}/share/info} --sysconfdir=/etc --localstatedir=/var --disable-option-checking --disable-silent-rules {--libdir=${prefix}/lib/x86_64-linux-gnu} {--libexecdir=${prefix}/lib/x86_64-linux-gnu} --disable-maintainer-mode --disable-dependency-tracking --mandir=/usr/share/man --libexecdir=/usr/libexec --with-mailpath=/var/mail --gpgme --lua --notmuch --with-ui=slang --gnutls --gss --idn --mixmaster --sasl --tokyocabinet --sqlite --autocrypt
endef

################################################################################
# hosts

hosts.target = $(HOME)/.config/hosts/update_hosts.sh

define hosts.setup-recipe
$(HOME)/.config/hosts/update_hosts.sh -l "$(dir $(hosts.target))"
endef

################################################################################\
# fonts

fonts.package-dependencies := fontconfig fonts-font-awesome
fonts.setup-recipe = fc-cache -v -f;

################################################################################
# Misc

X.package-dependencies := rxvt-unicode

ranger.package-dependencies := ranger

tmux.package-dependencies := tmux

dircolors.pip-dependencies := dircolors

updateable := firefox hosts

backup:
	tools/snapshot/snapshot.sh -s ~ -d /run/media/david/2TB/backups -p -i ~/.rsync/include
