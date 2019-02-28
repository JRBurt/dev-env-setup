
# ----- ALIASES -------------------------------------------------------- #
alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'
alias ll="ls -lhA"
alias sl="ls"
alias ps="ps aux"
alias mkdir="mkdir -p"
alias top="htop"
alias ..="cd .."
alias ....="cd ../.."
# ---------------------------------------------------------------------- #



# ----- FUNCTIONS ------------------------------------------------------ #
# Function which prints current Git branch name (used in prompt)
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
# ---------------------------------------------------------------------- #



# ----- FORMATTING ----------------------------------------------------- #
export CLICOLOR=1 # Enable ANSI colors sequences to distinguish file types
export LSCOLORS=GxFxCxDxBxegedabagaced # Value of this variable describes what color to use for which file type

# Color definitions (used in prompt)
RED='\[\033[1;31m\]'
GREEN='\[\033[1;32m\]'
YELLOW='\[\033[1;33m\]'
PURPLE='\[\033[1;35m\]'
GRAY='\[\033[1;30m\]'
DEFAULT='\[\033[0m\]'
# ---------------------------------------------------------------------- #



# ----- PROMPT --------------------------------------------------------- #
# Configure prompt
PS1="${GREEN}\h" # Hostname
PS1+=" ${GRAY}• " # Separator
PS1+="${RED}\u" # Username
PS1+=" ${GRAY}• " # Separator
PS1+="${YELLOW}\w" # Working directory
PS1+=" ${GRAY}\$([[ -n \$(git branch 2> /dev/null) ]] && echo \"•\") " # Separator (if there is a Git repository)
PS1+="${PURPLE}\$(parse_git_branch)" # Git branch
PS1+="\n" # New line
PS1+="${GRAY}\$ " # Dollar sign
PS1+="${DEFAULT}" # Get back default color

export PS1;
# ---------------------------------------------------------------------- #
