###################################################################################################
#                                             ALIASES                                             #
###################################################################################################

# -- -- -- Terminal -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

alias brewup='brew upgrade; brew cleanup; brew doctor'
alias ll="ls -lhA"
alias sl="ls"
alias ps="ps aux"
alias mkdir="mkdir -p"
alias top="htop"
alias ..="cd .."
alias ....="cd ../.."
alias proj="cd ~/projects"


# -- -- -- Python -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

alias venv='source venv/bin/activate'
alias venv11='source venv/bin/activate11'
alias venv12='source venv/bin/activate12'
alias venv13='source venv/bin/activate13'
alias pipreqs='pip install -r requirements.txt'


# -- -- -- AWS cli -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

alias s3ls='aws s3 ls'
alias s3sync='aws s3 sync'


# -- -- -- System Utilities -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

alias ports='lsof -i -P -n | grep LISTEN'
alias myip='curl ifconfig.me'
alias cleanup='find . -name "*.pyc" -delete && find . -name "__pycache__"
-delete'
alias dud='du -h -d 1 | sort -h'  # disk usage by directory


# -- -- -- Terraform -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'



###################################################################################################
#                                            FUNCTIONS                                            #
###################################################################################################

parse_virtualenv() {
  # Sets virtual env, for terminal decorator
  if test -z "$VIRTUAL_ENV" ; then
      echo ""
  else
      echo "`basename \"$VIRTUAL_ENV\"`"
  fi
}

parse_git_branch() {
  # Sets git branch, for terminal decorator
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

mkcdir () {
  # Makes and then moves into a new directory
  mkdir -p -- "$1" &&
    cd -P -- "$1"
}

extract() {
  # Extracts any archive file
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2) tar xjf $1 ;;
      *.tar.gz) tar xzf $1 ;;
      *.zip) unzip $1 ;;
      *.tgz) tar xzf $1 ;;
      *) echo "'$1' cannot be extracted" ;;
    esac
  fi
}



###################################################################################################
#                                           FORMATTING                                            #
###################################################################################################

export CLICOLOR=1 # Enable ANSI colors sequences to distinguish file types
export LSCOLORS=GxFxCxDxBxegedabagaced # Value of this variable describes what color to use for which file type
export GREP_OPTIONS='--color=auto'

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



###################################################################################################
#                                             PROMPT                                              #
###################################################################################################

# Configure prompt
PS1="${GREEN}\h" # Hostname
PS1+="${DARK_GRAY} • " # Separator
PS1+="${RED}\u" # Username
PS1+="${DARK_GRAY} • " # Separator
PS1+="${CYAN}\$(parse_virtualenv)" # Virtual Environment
PS1+="${DARK_GRAY}\$([[ -n \$VIRTUAL_ENV ]] && echo \" •\") " # Separator (if there is a virtualenv active)
PS1+="${YELLOW}\w" # Working directory
PS1+="${DARK_GRAY}\$([[ -n \$(git branch 2> /dev/null) ]] && echo \" •\") " # Separator (if there is a Git repository)
PS1+="${PURPLE}\$(parse_git_branch)" # Git branch
PS1+="\n" # New line
PS1+="${DARK_GRAY}\$ " # Dollar sign
PS1+="${DEFAULT}" # Get back default color

export PS1;
