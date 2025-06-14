# .bashrc

#
# Source global definitions
#

if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

#
# User specific environment
#

if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

#
# User specific aliases and functions
#

alias update='~/Repositórios/ConfigFiles/update-system.sh'
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

#
# Prompt customization
#

set_truncated_pwd() {
  # Define the maximum length of the directory path to display.
  local PWD_MAX_LEN=40

  # Define a symbol to use for truncation indication.
  local TRUNCATION_SYMBOL="..."

  # Extract the current directory name and replace the home directory with a tilde.
  local DIR=${PWD##*/}
  TRUNCATED_PWD=${PWD/#$HOME/\~}

  # Update PWD_MAX_LEN to ensure it's not less than the length of the current directory.
  PWD_MAX_LEN=$(( ( PWD_MAX_LEN < ${#DIR} ) ? ${#DIR} : PWD_MAX_LEN ))
  
  # Calculate the offset for truncation.
  local PWD_OFFSET=$(( ${#TRUNCATED_PWD} - PWD_MAX_LEN ))

  # If the path exceeds the maximum length, truncate it.
  if [ ${PWD_OFFSET} -gt "0" ]; then
    TRUNCATED_PWD=${TRUNCATED_PWD:$PWD_OFFSET:$PWD_MAX_LEN}
    TRUNCATED_PWD=${TRUNCATION_SYMBOL}/${TRUNCATED_PWD#*/}
  fi
}

format_text() {
  # Define variables for the format code
  local EFFECT=$1
  local FONT_COLOR=$(($2 + 30))
  local BG_COLOR=$(($3 + 40))

  # Return the format code
  echo -e "\[\033[${EFFECT};${FONT_COLOR};${BG_COLOR}m\]"
}

set_prompt() {
  # Define the terminal title
  local TITLEBAR="\[\033]0;\${TRUNCATED_PWD}\007\]"

  # Combine all arguments into a single string
  local PROMPT_SECTIONS=""
  for ARG in "${@}"; do
    PROMPT_SECTIONS+="${ARG}"
  done

  # Set the prompt
  PS1="${TITLEBAR}${PROMPT_SECTIONS}"
}

generate_prompt() {
  # Define colors
  local DEFAULT='9'
  local BLACK='0'
  local RED='1'
  local GREEN='2'
  local YELLOW='3'
  local BLUE='4'
  local MAGENTA='5'
  local CYAN='6'
  local LIGHT_GRAY='7'
  local DARK_GRAY='60'
  local LIGHT_RED='61'
  local LIGHT_GREEN='62'
  local LIGHT_YELLOW='63'
  local LIGHT_BLUE='64'
  local LIGHT_MAGENTA='65'
  local LIGHT_CYAN='66'
  local WHITE='67'

  # Define effects
  local NONE='0'
  local BOLD='1'
  local UNDERLINE='4'
  local BLINK='5'
  local REVERSE='7'
  local HIDDEN='8'

  # Define symbols
  local TRIANGLE=$'\uE0B0'
  local EMPTY_SPACE=$'\u2800'

  # Generate format codes
  local SECTION_FORMAT_1=$(format_text $NONE $WHITE $BLACK)
  local SECTION_FORMAT_2=$(format_text $NONE $BLACK $DARK_GRAY)
  local SECTION_FORMAT_3=$(format_text $NONE $WHITE $DARK_GRAY)
  local SECTION_FORMAT_4=$(format_text $NONE $DARK_GRAY $LIGHT_GRAY)
  local SECTION_FORMAT_5=$(format_text $NONE $BLACK $LIGHT_GRAY)
  local SECTION_FORMAT_6=$(format_text $NONE $LIGHT_GRAY $DEFAULT)
  local SECTION_FORMAT_7=$(format_text $NONE $DEFAULT $DEFAULT)

  # Generate prompt sections
  local SECTION_1="${SECTION_FORMAT_1}${EMPTY_SPACE}$(date +%H:%M)${EMPTY_SPACE}"
  local SECTION_2="${SECTION_FORMAT_2}${TRIANGLE}"
  local SECTION_3="${SECTION_FORMAT_3}${EMPTY_SPACE}\u${EMPTY_SPACE}"
  local SECTION_4="${SECTION_FORMAT_4}${TRIANGLE}"
  local SECTION_5="${SECTION_FORMAT_5}${EMPTY_SPACE}\${TRUNCATED_PWD}${EMPTY_SPACE}"
  local SECTION_6="${SECTION_FORMAT_6}${TRIANGLE}"
  local SECTION_7="${SECTION_FORMAT_7}${EMPTY_SPACE}"

  # Set the prompt
  set_prompt $SECTION_1 $SECTION_2 $SECTION_3 $SECTION_4 $SECTION_5 $SECTION_6 $SECTION_7
}

# PROMPT_COMMAND holds commands or functions that run before each new Bash prompt is displayed.
PROMPT_COMMAND='set_truncated_pwd; generate_prompt'

# Generate the prompt
generate_prompt
