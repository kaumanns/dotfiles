# My dotfiles

Fancy GNU stow wrapper for easy setup of GNU/Linux systems with personal tools and configurations.

Supports git submodules (e.g. for vim extensions).

**WARNING**: this solution is still experimental. I recommend taking the code and the dotfiles only as a reference for your own solution.

## Installation

Install tools and initialize submodules:

```
$ make init
```

## Usage

1. Put all files that you want to see in `$HOME` into subdirectories in `home/`.

The organization and names of the subdirectories are up to you.
It makes sense to separate different tools, e.g. `zsh` from `vim`, as they may require different setups.
But theoretically, all files could be put into a single subdirectory.

Examples:

```
home/zsh/dot-zshrc
home/vim/dot-vim.rc
home/firefox/.mozilla/firefox/user.js
```

2. Create your personal configuration in `config.mk`, per given examples.

For each subdirectory, symlinks to its files are stowed and a setup routine is run.

The Make recipe for each setup routine can be controlled either directly by implementing `<toolname>.setup`, or by instantiating any subset of the following pre-defined variables:

- `<subdir>.setup-recipe`: Bash commands for setup, installation, compilation, etc.
- `<subdir>.prerequisites`: File prerequisites
- `<subdir>.order-only-prerequisites`: Order-only prerequisites, e.g. other stows (zsh depends on `dircolors.stow`). Use this variable to ensure a certain order of setups.
  - `<subdir>.package-dependencies`: System packages to be installed.
  - `<subdir>.pip-dependencies`: Pip modules to be installed.
  - `<subdir>.required-directories`: Directories to be ensured.

The variable names indicate their internal organization, as per GNU Make syntax.
Look into `Makefile` for details.

3. Run stows and setups for all subdirectories in `home/`:

```
$ make
```

Optionally, run individual stows and setups, as such:

```
$ make zsh.stow
$ make vim.setup
```

Once in a while, update and pull submodules from remote heads:

```
$ make update
```

## BUGS

There is a bug in GNU stow that forbids using the `dot-` prefix (for the `--dotfiles` option) with some (?) directories.
The error looks like this:

```
stow: ERROR: stow_contents() called with non-directory path: git/dotfiles/home/gnupg/.gnupg
```

Workaround: Use `.` prefix for dot-directories, e.g. `.config`.

## TODO

- Enable stowing into root (or should I?).
- "Install" tools as aliases into zshrc.
- Make quick st font size change more convenient (e.g. for changing devices/screens)
