# ----- ALIASES -------------------------------------------------------- #
alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'
alias ll="ls -lhA"
alias sl="ls"
alias ps="ps aux"
alias mkdir="mkdir -p"
alias top="htop"
alias ..="cd .."
alias ....="cd ../.."
alias proj="cd ~/projects"
# ---------------------------------------------------------------------- #


# ----- virtualenv and virtualenvwrapper ------------------------------- #
# export WORKON_HOME=$HOME/.virtualenvs
#
# export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
#
# source /usr/local/bin/virtualenvwrapper.sh
# ---------------------------------------------------------------------- #


# ----- FUNCTIONS ------------------------------------------------------ #
# Function which prints current Git branch name (used in prompt)
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Determine active Python virtualenv details.
# set_virtualenv () {
#   if test -z "$VIRTUAL_ENV" ; then
#       ""
#   else
#       "[`basename \"$VIRTUAL_ENV\"`]"
#   fi
# }
# ---------------------------------------------------------------------- #



# ----- FORMATTING ----------------------------------------------------- #
export CLICOLOR=1 # Enable ANSI colors sequences to distinguish file types
export LSCOLORS=GxFxCxDxBxegedabagaced # Value of this variable describes what color to use for which file type

# Color definitions (used in prompt)
RED="\[\033[1;31m\]"
YELLOW="\[\033[1;33m\]"
LIGHT_YELLOW="\[\033[1;93m\]"
GREEN="\[\033[1;32m\]"
BLUE="\[\033[1;34m\]"
CYAN="\[\033[1;36m\]"
PURPLE="\[\033[1;35m\]"
LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
WHITE="\[\033[1;37m\]"
LIGHT_GRAY="\[\033[1;37m\]"
DARK_GRAY="\[\033[1;90m\]"
DEFAULT="\[\e[0m\]"
# ---------------------------------------------------------------------- #



# ----- PROMPT --------------------------------------------------------- #
# Configure prompt
# PS1="\$(set_virtualenv)" # Virtual Environment
PS1="${GREEN}\h" # Hostname
PS1+=" ${DARK_GRAY}• " # Separator
PS1+="${RED}\u" # Username
PS1+=" ${DARK_GRAY}• " # Separator
PS1+="${YELLOW}\w" # Working directory
PS1+=" ${DARK_GRAY}\$([[ -n \$(git branch 2> /dev/null) ]] && echo \"•\") " # Separator (if there is a Git repository)
PS1+="${PURPLE}\$(parse_git_branch)" # Git branch
PS1+="\n" # New line
PS1+="${DARK_GRAY}\$ " # Dollar sign
PS1+="${DEFAULT}" # Get back default color

export PS1;

# ----- PATH ----------------------------------------------------------- #

