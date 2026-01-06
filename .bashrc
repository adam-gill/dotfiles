# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

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
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias c='clear'
alias dev='npm run dev'
alias keyboard-replacements='vim ~/.config/espanso/match/base.yml'
alias copy-tree='tree -a -I "node_modules|.next|tiptap|.git" | xclip -selection clipboard'
alias brc='vim /home/tyler/.bashrc'
alias rld='source /home/tyler/.bashrc'

# prints length of a given video file

vidlen() {
    if [[ -z "$1" ]]; then
        echo "Error: No file provided."
        echo "Usage: get_video_duration <video_file>"
        return 1
    fi

    if [[ ! -f "$1" ]]; then
        echo "Error: File '$1' not found."
        return 1
    fi

    local duration=$(ffmpeg -i "$1" 2>&1 | grep "Duration" | awk '{print $2}' | tr -d ',' | awk -F ':' '{print ($1 * 3600) + ($2 * 60) + $3}')

    if [[ -z "$duration" ]]; then
        echo "Error: Could not extract duration from '$1'."
        return 1
    fi

    echo "$duration"
}

# count the number of each file extension in the current directory

extcount() {
    local extensions=$(find . -maxdepth 1 -type f | sed -E 's/.*\.([^.]+)$/\1/' | grep -v '^$' | sort | uniq -c | sort -nr)
    local total_files=$(find . -maxdepth 1 -type f | wc -l)

    echo "File extensions in current directory:"
    echo "-----------------------------------"
    echo "$extensions"
    echo "-----------------------------------"
    echo "Total files: $total_files"
}


# function to print the created/modified times of a given file

age() {
    if [ -z "$1" ]; then
        echo "Usage: age <file>"
        return 1
    fi

    if [ ! -e "$1" ]; then
        echo "Error: File '$1' does not exist."
        return 1
    fi

    stat -c '%w | %y' "$1" | awk -F '|' '{ printf "Created: %s\nModified: %s\n", $1, $2 }'
}

# function to count the number of items in a given directory

count() {
    if [ -z "$1" ]; then
        echo "Usage: count /path/to/directory"
        return 1
    fi

    if [ ! -d "$1" ]; then
        echo "Error: '$1' is not a valid directory."
        return 1
    fi

    ls -1A "$1" | wc -l
}

# function to record audio computer is playing (q to quit recording)

record() {
    local filename="output$(shuf -i 1000-9999 -n 1).mp3"
    ffmpeg -f pulse -i alsa_output.pci-0000_00_1f.3.analog-stereo.monitor -codec:a libmp3lame -qscale:a 0 "$filename"
}

# function to copy text of a file to clipboard

clip() {
  if [ -f "$1" ]; then
    xclip -selection clipboard < "$1"
    echo "Copied $1 to clipboard"
  else
    echo "File not found: $1"
  fi
}

# funciton to get public ip address (IPv4 preferred)

ipchicken() {
    # Fetch the HTML content of ipchicken.com
    html_content=$(curl -s https://ipchicken.com)

    # Use a regex to extract the first IP address (IPv4 or IPv6) from the HTML content
    ip_address=$(echo "$html_content" | grep -oP '(\b(?:\d{1,3}\.){3}\d{1,3}\b|\b(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}\b)' | head -n 1)

    # If no IP address is found, fallback to ifconfig.me
    if [[ -z "$ip_address" ]]; then
        echo "No IP address found in ipchicken.com. Falling back to ifconfig.me."
        ip_address=$(curl -s ifconfig.me)
    fi

    echo "$ip_address"
}

# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

eval "$(starship init bash)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
. "/home/tyler/.deno/env"

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# pnpm
export PNPM_HOME="/home/tyler/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end