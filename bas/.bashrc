#
# ~/.bashrc
#

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

###########
# General #
###########

# Auto "cd" when entering just a path
shopt -s autocd 2> /dev/null

# Line wrap on window resize
shopt -s checkwinsize 2> /dev/null

# Case-insensitive tab completetion
bind -s 'set completion-ignore-case on'

# When displaying tab completion options, show just the remaining characters
bind 'set completion-prefix-display-length 2'

# Show tab completion options on the first press of TAB
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'


########
# Path #
########

# PATH=/usr/local/bin:$PATH
# PATH=~/.composer/vendor/bin:$PATH
# PATH=./vendor/bin:$PATH
# PATH=~/.bin:$PATH
# PATH=~/Scripts:$PATH

###########
# History #
###########

# Append to the Bash history file, rather than overwriting
shopt -s histappend 2> /dev/null

# Hide some commands from the history
#export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help";

# Entries beginning with space aren't added into history, and duplicate
# entries will be erased (leaving the most recent entry).
export HISTCONTROL="ignorespace:erasedups"

# Give history timestamps.
export HISTTIMEFORMAT="[%F %T] "

# Lots o' history.
export HISTSIZE=10000
export HISTFILESIZE=10000


#############
# Functions #
#############

# Search in files
sif() {
    grep -EiIrl "$*" .
}

# # Colored man pages
# man() {
#     env LESS_TERMCAP_mb=$'\E[01;31m' \
#     LESS_TERMCAP_md=$'\E[01;38;5;74m' \
#     LESS_TERMCAP_me=$'\E[0m' \
#     LESS_TERMCAP_se=$'\E[0m' \
#     LESS_TERMCAP_so=$'\E[38;5;246m' \
#     LESS_TERMCAP_ue=$'\E[0m' \
#     LESS_TERMCAP_us=$'\E[04;38;5;146m' \
#     man "$@"
# }


# get current branch in git repo
function parse_git_branch() {
    BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
    if [ ! "${BRANCH}" == "" ]
    then
            STAT=`parse_git_dirty`
            echo "[${BRANCH}${STAT}]"
    else
            echo ""
    fi
    
}

# get current status of git repo
function parse_git_dirty {
    status=`git status 2>&1 | tee`
    dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
    untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
    ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
    newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
    renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
    deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
    bits=''
    if [ "${renamed}" == "0" ]; then
            bits=">${bits}"
    fi
    if [ "${ahead}" == "0" ]; then
            bits="*${bits}"
    fi
    if [ "${newfile}" == "0" ]; then
            bits="+${bits}"
    fi
    if [ "${untracked}" == "0" ]; then
            bits="?${bits}"
    fi
    if [ "${deleted}" == "0" ]; then
            bits="x${bits}"
    fi
    if [ "${dirty}" == "0" ]; then
            bits="!${bits}"
    fi
    if [ ! "${bits}" == "" ]; then
            echo " ${bits}"
    else
            echo ""
    fi
}

bash_prompt_command() {
    # set a fancy prompt (non-color, unless we know we "want" color)
    case "$TERM" in
        xterm-color|*-256color) color_prompt=yes;;
    esac

    # uncomment for a colored prompt, if the terminal has the capability; turned
    # off by default to not distract the user: the focus in a terminal window
    # should be on the output of commands, not on the prompt
    #force_color_prompt=yes

    if [ -n "$force_color_prompt" ]; then
        if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
        else
        color_prompt=
        fi
    fi

    if [ "$color_prompt" = yes ]; then
        # PS1="\[\e]0;\w\a\]\[\033[33;1m\]\$(basename \w): \[\033[36m\]\$(basename \w) \$\[\033[m\] "
        PS1="\[\e]0;\w\a\]\[\033[36m\]\$(basename \w) \[\033[33;1m\]$(parse_git_branch) \$\[\033[m\] "
    else
        PS1="\[\e]0;\w\a\]\u:\$(basename \w) \$ "
    fi
    unset color_prompt force_color_prompt

    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\w\a\]$PS1"
        ;;
    *)
        ;;
    esac
}

###########
# Exports #
###########

# export EDITOR="vim"

###########
# Aliases #
###########

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # OS X `ls`
	colorflag="-G"
fi

alias ls='ls -lhF ${colorflag}'
alias la='ls -A'

alias grep='grep --color=auto -n -i'
alias cls="clear"

alias df="df -h"
alias du="du -h"
alias free="free -h"

alias ..="cd .."
alias home="cd ~/projects"

if [ -f /usr/bin/xdg-open ]; then
    alias open='/usr/bin/xdg-open'
fi


################################################################################
##  PROMPT_COMMAND                                                            ##
################################################################################

##	Bash provides an environment variable called PROMPT_COMMAND. 
##	The contents of this variable are executed as a regular Bash command 
##	just before Bash displays a prompt. 
##	We want it to call our own command to truncate PWD and store it in NEW_PWD
PROMPT_COMMAND=bash_prompt_command

##	Call bash_promnt only once, then unset it (not needed any more)
##	It will set $PS1 with colors and relative to $NEW_PWD, 
##	which gets updated by $PROMT_COMMAND on behalf of the terminal
# bash_prompt
# unset bash_prompt
unset rc