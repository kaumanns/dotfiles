################################################################################
# Make configuration

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

# INSTALL_CMD := sudo apt install -y
INSTALL_CMD := sudo pacman --needed --noconfirm -Sy

################################################################################
# Functions

dirs = $(shell ls $(1))
package-install = $(INSTALL_CMD) $(1)
pip-install = $(PIP) install --upgrade --user $(1)
stow = $(STOW) --restow --verbose 1 --dotfiles --dir $(STOW_DIR) --target $(1) $(2)

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

stow: $(addsuffix .stow,$(STOW_SUBDIRS)) | update
.PHONY: stow

################################################################################
# Methods

%.stow:
	$(call stow,~,$*)
	$(MAKE) $*.setup

# TODO
# %.root:
# 	sync
# 	$(call stow,/,$*)

%.package-install:
	$(call package-install,$*)

%.pip-install:
	$(call pip-install,$*)

%.mkdir:
	@[[ -d $* ]] || mkdir -p $*

define setup_template
$1.setup: $$($1.prerequisites) | $$($1.order-only-prerequisites) $$(addsuffix .package-install,$$($1.package-dependencies)) $$(addsuffix .pip-install,$$($1.pip-dependencies)) $$(addsuffix .mkdir,$$($1.required-directories))
	$$($1.setup-recipe)
endef

$(foreach dir,$(STOW_SUBDIRS),$(eval $(call setup_template,$(dir))))

%.setup:
	@echo "No setup instructions defined for $* -- skipping."
