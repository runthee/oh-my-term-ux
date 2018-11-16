# vim:ft=zsh ts=2 sw=2 sts=2
#
# Termix
# A simple and fancy theme based on agnoster's Theme(https://gist.github.com/3712874)
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
# Special Powerline characters

 {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.
  # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
  SEGMENT_SEPARATOR=$'\ue0b0''\ue0b1 '
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: Device/Android Version
prompt_context() {
  prompt_segment yellow black "%F{black}\uf49b%f%@"
	prompt_segment black cyan "%F{yellow}\uf415%f %n"
  prompt_segment red white "%B\uf490%b %B%h%b"
 }
#prompt_segment yellow black "`getprop ro.product.model`"

# Dir: current working directory
prompt_dir() {
	prompt_segment blue white "%F{yellow}\ue5fe%f %2d"
#echo -n $PWD | sed -e "s|^$HOME|~|" -e 's|\(\.\{0,1\}[^/]\)[^/]*/|\1/|g'
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment blue green "(`basename $virtualenv_path`)"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbol
  symbols=()
  [[ $UID -eq 0 ]] && symbols+="⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+='\ue70e'
  symbols+="%B%F{green}\uf21e%f%b %? %B%F{red}%I%f%b %J"
  prompt_segment %Bblack%b white "$symbols"
}

function battery_charge {
	    echo `$BAT_CHARGE` 2>/dev/null
		}

## Main prompt
build_prompt() {
  prompt_context
  prompt_virtualenv
  prompt_dir
  prompt_end
}

build_prompt_s() {
  RETVAL=$?
  prompt_status
  prompt_end

}

build_prompt_right() {
	right_prompt
	prompt_end
}
PROMPT='%{%f%b%k%}$(build_prompt) 
$(build_prompt_s)'
RPROMPT='$(battery_charge)'
