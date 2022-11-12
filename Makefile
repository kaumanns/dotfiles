################################################################################
# Make configuration

# Use bash in strict mode
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

.ONESHELL:
.SECONDARY:
.DELETE_ON_ERROR:
.SECONDEXPANSION:

# MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

################################################################################
# Macros

SILENT := @
TIME := echo "---" && time

GIT := git
PIP := pip3
STOW := stow
STOW_DIR := home

################################################################################
# Functions

dirs = $(shell ls $(1))

# OS_NAME := $(patsubst NAME=%,%,$(shell cat /etc/*-release | grep "^NAME="))
OS_NAME := $(shell uname)

ifeq ($(OS_NAME), "Arch Linux")
	package-install = pacman -Q | grep "^$1 " || sudo pacman --needed --noconfirm --upgrade --refresh--sync $1
else ifeq  ($(OS_NAME), "Debian")
	package-install = sudo apt install -y $1
else ifeq  ($(OS_NAME), "Darwin")
	package-install = brew install
endif

pip-install = $(PIP) install --upgrade --user $(1)

git-clone = [[ -z $(2) ]] && git clone $(1) $(2)

# stow = $(STOW) --restow --verbose 1 --dotfiles --dir $(STOW_DIR) --target $(1) $(2)

STOW_SUBDIRS = $(call dirs,$(STOW_DIR))

################################################################################
# User config

default: stow
.PHONY: default

include config.mk

################################################################################
# Hooks

REQUIRED_PACKAGES = stow git python3

install:
	$(call package-install,$(REQUIRED_PACKAGES))
.PHONY: install

init: | install
	$(GIT) submodule update --init --recursive
.PHONY: init

# NOTE: Not doing recursive update because it breaks dependencies managed by submodules.
update: update-submodules | init
	$(MAKE) $(if $(updateable),$(addsuffix .setup,$(updateable)))
.PHONY: update

update-submodules:
	$(GIT) submodule update --remote
	$(GIT) submodule foreach '$(GIT) checkout master && $(GIT) pull'
.PHONY: update-submodules

# stow: $(addsuffix .stow,$(STOW_SUBDIRS)) | update
# .PHONY: stow

################################################################################
# Methods

# TODO
# %.root:
# 	sync
# 	$(call stow,/,$*)

%.mkdir:
	@[[ -d $* ]] || mkdir -p $*

define stow =
	$(STOW) \
		--restow \
		--verbose 1 \
		--dotfiles \
		--dir $(dir $1) \
		--target $2 \
		$(notdir $1)
endef

# Iterate over source directories and build rules for stowing and setting up.
define stow_template
$$($1.target): $(STOW_DIR)/$1
	$$(call stow,$$<,$(HOME))
	$$(MAKE) $$@.setup

$1.setup: $$($1.prerequisites) | $$($1.order-only-prerequisites)
	$$(if $$($1.package-dependencies),$$(call package-install,$$($1.package-dependencies)))
	$$(if $$($1.pip-dependencies),$$(call pip-install,$$($1.pip-dependencies)))
	$$($1.setup-recipe)
	@echo "DONE"

$1: $$($1.target)

endef
# $(foreach dir,$(STOW_SUBDIRS),$(info $(call stow_template,$(dir))))
$(foreach dir,$(STOW_SUBDIRS),$(eval $(call stow_template,$(dir))))

%.setup:
	@echo "No setup instructions defined for $* -- skipping."

