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

################################################################################
# Functions

dirs = $(shell ls $(1))
package-install = sudo apt install -y $(1)
pip-install = $(PIP) install --upgrade --user $(1)
stow = $(STOW) --verbose 1 --dotfiles --dir $(STOW_DIR) --target $(1) $(2)

################################################################################
# User config

include config.mk

################################################################################
# Helper targets

REQUIRED_PACKAGES = stow git python3-pip

init: install
	$(GIT) submodule update --init --recursive
.PHONY: init

install:
	$(call package-install,$(REQUIRED_PACKAGES))
.PHONY: install

# NOTE: Not doing recursive update because it breaks dependencies managed by submodules.
update:
	$(GIT) submodule update --remote
	$(GIT) submodule foreach '$(GIT) checkout master && $(GIT) pull'
.PHONY: update

################################################################################
# Generic targets

%.stow:
	$(call stow,~,$*)
	$(MAKE) $*.setup

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

%.setup:
	@echo "No setup instructions defined for $* -- skipping."

# This generates an eval to setup_template for each directory in the source directory.
define setup_template_template
$(foreach dir,$(call dirs,$(STOW_DIR)),$$(eval $$(call setup_template,$(dir))))
endef

$(eval $(call setup_template_template))
