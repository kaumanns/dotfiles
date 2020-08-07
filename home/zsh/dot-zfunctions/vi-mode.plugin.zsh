# Handle Tmux
function _set_cursor() {
    if [[ $TMUX = '' ]]; then
        echo -ne $1
    else
        echo -ne "\ePtmux;\e\e$1\e\\"
    fi
}

function _set_block_cursor() { _set_cursor '\e[2 q' }
function _set_beam_cursor() { _set_cursor '\e[6 q' }

# Updates editor information when the keymap changes.
function zle-keymap-init zle-keymap-select {
  # update keymap variable for the prompt
  VI_KEYMAP=$KEYMAP

  zle reset-prompt
  zle -R

  if [ $KEYMAP = vicmd ]; then
      # normal mode
      _set_block_cursor
  else
      # insert mode
      _set_beam_cursor
  fi
}

zle -N zle-keymap-init
zle -N zle-keymap-select

_fix_cursor() {
    echo -ne "\e[6 q"
}

precmd_functions+=(_fix_cursor)

function vi-accept-line() {
  VI_KEYMAP=main
  zle accept-line
}

zle -N vi-accept-line


bindkey -v

# use custom accept-line widget to update $VI_KEYMAP
bindkey -M vicmd '^J' vi-accept-line
bindkey -M vicmd '^M' vi-accept-line

# allow v to edit the command line (standard behaviour)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'V' edit-command-line

# allow ctrl-p, ctrl-n for navigate history (standard behaviour)
bindkey '^P' up-history
bindkey '^N' down-history

# allow ctrl-h, ctrl-w, ctrl-? for char and word deletion (standard behaviour)
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

# allow ctrl-r and ctrl-s to search the history
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward

# allow ctrl-a and ctrl-e to move to beginning/end of line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

