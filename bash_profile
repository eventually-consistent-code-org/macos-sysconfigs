# ============================================================================
# ~/.bash_profile  (mirror of macos-sysconfigs/bash_profile)
# macOS bash configuration -- merged from live ~/.bash_profile and the
# macos-sysconfigs repo copy.  Repo is the source of truth.
# ============================================================================

# If not running interactively, don't do anything.
# (Guards against this profile firing during scp / non-interactive contexts.)
case $- in
    *i*) ;;
      *) return;;
esac

# ----------------------------------------------------------------------------
# History
# ----------------------------------------------------------------------------
# Drop duplicates and lines starting with space from history.
HISTCONTROL=ignoreboth
# Append to history file instead of overwriting on shell exit.
shopt -s histappend
# History sizes (in-memory entries / on-disk lines).
HISTSIZE=1000
HISTFILESIZE=2000

# Re-check window size after each command and update LINES/COLUMNS.
shopt -s checkwinsize

# ----------------------------------------------------------------------------
# Homebrew environment  (must run before PATH export so brew bins are present)
# ----------------------------------------------------------------------------
eval "$(/opt/homebrew/bin/brew shellenv bash)"

# ----------------------------------------------------------------------------
# Exports / environment
# ----------------------------------------------------------------------------
# PATH: prepend personal + local bins, keep system PATH at the end.
# Uses $HOME so this file works across machines / username changes.
export PATH="/usr/local/bin:/usr/local/sbin:$HOME/.darkbloom/bin:$HOME/opt/homebrew/bin:$HOME/.local/bin:$HOME/repos/aws-profile-bash-prompt:$PATH"

# Default editor for shell tools, git, svn, crontab, etc.
export EDITOR='vim'
export SVN_EDITOR='vim'

# Terragrunt cache target (used by tg/terragrunt operations).
export TG_DOWNLOAD_DIR="/tmp/terragrunt/cache"

# AWS credentials file path (template placeholder; override per environment).
export AWS_CREDENTIAL_FILE=~/aws/credential-file-path.template

# Colored GCC compiler warnings/errors.
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Jira Env
export JIRA_EMAIL='john@eventually-consistent.io'
export JIRA_API_TOKEN='ATATT3xFfGF0SmTsEj-agCne-VghBRioNr0S_zMDc4fNfWnIpo0Sqril-GFHnOHDB2r-mKj0VgXxbConN-KLmZGCSqe50ivS6ZYNFg6kmcmVlaIWAS-wyc9363U3Yax6za85mCFHbebRTKnCW_QHpeafqmi4tvMEz896WXuRQoxxgOAXSF5XbWc=89BF5EBC'

# Homebrew libffi linker hint (helps Python/C extension builds find libffi).
export LDFLAGS="-L/usr/local/opt/libffi/lib"

# ls / du / df default blocksize -- 1KB blocks (more readable than 512B).
export BLOCKSIZE=1k

# Enable colorized output for BSD ls + friends, and pick a color scheme.
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# ----------------------------------------------------------------------------
# Optional aliases file
# ----------------------------------------------------------------------------
# Pull in additional aliases if a separate file exists.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ----------------------------------------------------------------------------
# Prompt (PS1)
# ----------------------------------------------------------------------------
# Color variables used to compose PS1 (each is an escape-wrapped ANSI sequence).
BLACK="\[\e[0;30m\]"
DARK_GRAY="\[\e[1;30m\]"
RED="\[\e[0;31m\]"
YELLOW="\[\e[0;33m\]"
BLUE="\[\e[0;34m\]"
LIGHT_BLUE="\[\e[1;34m\]"
GREEN="\[\e[0;32m\]"
LIGHT_GREEN="\[\e[1;32m\]"
CYAN="\[\e[0;36m\]"
LIGHT_CYAN="\[\e[1;36m\]"
LIGHT_RED="\[\e[1;31m\]"
PURPLE="\[\e[0;34m\]"
LIGHT_PURPLE="\[\e[1;35m\]"
BROWN="\[\e[0;33m\]"
LIGHT_GRAY="\[\e[0;37m\]"
WHITE="\[\e[1;37m\]"

# Returns "(branch_name)" for the current repo, or empty string if not in one.
function parse_git_branch {
   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Prompt layout:  [user]:|host:|cwd:(git-branch):|
export PS1="\[${LIGHT_GRAY}\][\[${LIGHT_GREEN}\]\u\[${LIGHT_GRAY}\]]\[${LIGHT_GRAY}\]:|\[${LIGHT_GREEN}\]\h\[${LIGHT_GRAY}\]:|\[${LIGHT_CYAN}\]\w\[${LIGHT_GRAY}\]:\[${LIGHT_PURPLE}\]\$(parse_git_branch)\[${LIGHT_GRAY}\]:| \[${WHITE}\]"

# When running under xterm/rxvt, also set the window title to user@host: cwd.
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# ----------------------------------------------------------------------------
# Navigation helpers
# ----------------------------------------------------------------------------
# cd override that lists directory contents after every successful cd.
cd () {
    builtin cd "$@"
    ls -alGFh
}

# `..` with dot-counting: each extra `.` in the arg is another level up.
# Examples:
#   ..          -> cd ..                (no arg: classic single level up)
#   .. ..       -> cd ../..
#   .. ...      -> cd ../../..
#   .. ....     -> cd ../../../..
.. () {
  local times
  # No-arg form preserves the conventional `..` meaning (up one).
  if [ -z "$1" ]; then
    cd ..
    return
  fi
  # Count chars in the arg (incl. trailing newline) and step up that-minus-one times.
  times=$(echo $1 | wc -c)
  for ((i = 1; i < $times ; i++)); do
    cd ..
  done
}

# Numeric shortcuts retained for muscle memory from the live profile.
alias cd..='cd ../'                         # cd..:        Typo-tolerant "cd .."
alias .3='cd ../../../'                     # .3:          Go up 3 levels
alias .4='cd ../../../../'                  # .4:          Go up 4 levels
alias .5='cd ../../../../../'               # .5:          Go up 5 levels
alias .6='cd ../../../../../../'            # .6:          Go up 6 levels

alias repos='cd ~/repos'                    # repos:       Jump to ~/repos
alias ~="cd ~"                              # ~:           Go home

# ----------------------------------------------------------------------------
# Make the terminal better
# ----------------------------------------------------------------------------
alias fucking='/usr/bin/sudo'               # fucking:     sudo, but funnier
alias v='vim'                               # v:           Shortcut to vim
alias cp='cp -iv'                           # cp:          Interactive + verbose
alias mv='mv -iv'                           # mv:          Interactive + verbose
alias mkdir='mkdir -pv'                     # mkdir:       Create parents + verbose
alias ll='ls -alGFh'                        # ll:          Long listing with color
alias less='less -FSRXc'                    # less:        Quit-if-one-screen, raw control chars, no clear
alias c='clear'                             # c:           Clear terminal display
alias which='type -all'                     # which:       Find all executables matching name
alias path='echo -e ${PATH//:/\\n}'         # path:        Echo each PATH entry on its own line
alias show_options='shopt'                  # show_options:Display bash shopt settings
alias fix_stty='stty sane'                  # fix_stty:    Restore terminal settings when scrambled
alias cic='set completion-ignore-case On'   # cic:         Case-insensitive tab-completion
alias profile='source ~/.bash_profile'      # profile:     Reload this profile
alias edit='subl'                           # edit:        Open file in Sublime Text
alias f='open -a Finder ./'                 # f:           Open current directory in Finder
alias DT='tee ~/Desktop/terminalOut.txt'    # DT:          Tee terminal output to file on Desktop
alias brewup='brew update; brew upgrade; brew cleanup; brew doctor'   # brewup: Update + upgrade + cleanup + doctor
alias python='python3'                      #python        points python command to python3 install

# Recursive directory listing rendered as an indented tree, piped to less.
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'

# mcd: make a directory (with parents) and immediately cd into it.
mcd() { mkdir -p "$1" && cd "$1"; }

# trash: move file(s) to the macOS Trash instead of rm.
trash() { command mv "$@" ~/.Trash ; }

# ql: open a file in macOS Quicklook preview.
ql() { qlmanage -p "$*" >& /dev/null; }

# ----------------------------------------------------------------------------
# Date helpers
# ----------------------------------------------------------------------------
# Human-readable timestamp string (handy for snapshot/backup filenames).
hdate() {
  date "+%Y-%m-%d_%H-%M-%S"
}

# ----------------------------------------------------------------------------
# Git goodies
# ----------------------------------------------------------------------------
# gc: clone a repo (positional/quoted args forwarded).
gc () {
    git clone "$@"
}

# ginit: init a new git repo in the current directory.
ginit() {
    git init
}

# gcom: stage everything, commit with a message, push.  (Modern preferred form.)
gcom() {
    git add .
    git commit -am "$@"
    git push
}

# lg: stage everything, commit with a message, push.  (Legacy short form kept
# for muscle memory; equivalent to gcom for a single-word message.)
lg() {
    git add .
    git commit -a -m "$1"
    git push
}

# gp: pull current branch.
gp() {
    git pull
}

# gdiff: show working tree diff.
gdiff() {
    git diff
}

# gnewb: create a new branch (without checking it out).
gnewb() {
    git branch "$@"
}

# gchbranch: switch to an existing branch.
gchbranch() {
    git checkout "$@"
}

# gb: create a new branch AND switch to it (one-shot helper).
gb() {
    git branch "$1"
    git checkout "$1"
}

# gmerge: merge a named branch into the current branch.
gmerge () {
    git merge "$@"
}

# grebase: rebase current branch onto another.
grebase () {
    git rebase "$@"
}

# ----------------------------------------------------------------------------
# Claude Stuff
# ----------------------------------------------------------------------------

dangerclaude () {
claude --dangerously-skip-permissions
}

# ----------------------------------------------------------------------------
# SSH key generation
# ----------------------------------------------------------------------------
# keygen: interactive ed25519 key generation (modern; preferred over RSA-4096).
# Prompts for filename and email/comment; writes key to ~/.ssh/<name>.
keygen() {
  read -p "Enter key filename (e.g. id_github): " name
  read -p "Enter email/comment: " email
  ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/"$name"
}

# ----------------------------------------------------------------------------
# Searching
# ----------------------------------------------------------------------------
alias qfind="find . -name "                 # qfind:       Quickly find by exact name
ff () { /usr/bin/find . -name "$@" ; }      # ff:          Find file under cwd by exact name
ffs () { /usr/bin/find . -name "$@"'*' ; }  # ffs:         Find file whose name starts with given string
ffe () { /usr/bin/find . -name '*'"$@" ; }  # ffe:         Find file whose name ends with given string

# spotlight: query macOS Spotlight by display name.
spotlight () { mdfind "kMDItemDisplayName == '$@'wc"; }

# showa: remind yourself of an alias by grepping the aliases file.
showa () { /usr/bin/grep --color=always -i -a1 $@ ~/Library/init/bash/aliases.bash | grep -v '^\s*$' | less -FSRXc ; }

# ----------------------------------------------------------------------------
# Archive extraction
# ----------------------------------------------------------------------------
# extract: unpack most known archive types based on file extension.
extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
      esac
    else
      echo "'$1' is not a valid file"
    fi
}

# ----------------------------------------------------------------------------
# Process management
# ----------------------------------------------------------------------------
# findPid: list pid(s) for a process name.
findPid () { lsof -t -c "$@" ; }

# Memory hogs: top 20 by RSS via top; top 10 via ps.
alias memHogsTop='top -l 1 -o rsize | head -20'
alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'

# CPU hogs: top 10 by %CPU.
alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'

# topForever: long-running top, refresh every 10s, sorted by CPU.
alias topForever='top -l 9999999 -s 10 -o cpu'

# ttop: low-resource top invocation (no events, no UI, 10s refresh, by RSS).
alias ttop="top -R -F -s 10 -o rsize"

# my_ps: list processes owned by current user with useful columns.
my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,start,time,bsdtime,command ; }

# ----------------------------------------------------------------------------
# Networking
# ----------------------------------------------------------------------------
alias myip='curl ip.appspot.com'                    # myip:        Public-facing IP
alias netCons='lsof -i'                             # netCons:     All open TCP/IP sockets
alias flushDNS='dscacheutil -flushcache'            # flushDNS:    Flush macOS DNS cache
alias lsock='sudo /usr/sbin/lsof -i -P'             # lsock:       All open sockets
alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP'   # lsockU:      Open UDP sockets only
alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP'   # lsockT:      Open TCP sockets only
alias ipInfo0='ipconfig getpacket en0'              # ipInfo0:     en0 connection info
alias ipInfo1='ipconfig getpacket en1'              # ipInfo1:     en1 connection info
alias openPorts='sudo lsof -i | grep LISTEN'        # openPorts:   All listening ports
alias showBlocked='sudo ipfw list'                  # showBlocked: All ipfw rules (legacy macOS)

# ii: print host / network summary.
ii() {
    echo -e "\nYou are logged on ${RED}$HOST"
    echo -e "\nAdditional information:$NC " ; uname -a
    echo -e "\n${RED}Users logged on:$NC " ; w -h
    echo -e "\n${RED}Current date :$NC " ; date
    echo -e "\n${RED}Machine stats :$NC " ; uptime
    echo -e "\n${RED}Current network location :$NC " ; scselect
    echo -e "\n${RED}Public facing IP Address :$NC " ; myip
    echo
}
eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.bash 2>/dev/null || :eval "$(/opt/homebrew/bin/brew shellenv)"
