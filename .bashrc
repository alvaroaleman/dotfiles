# bashrc for alvaro-user

# Source bash completion
. /usr/share/bash-completion/bash_completion

# Variables
export EDITOR=/usr/bin/vim
export SYSTEMD_PAGER=

# Aliases
alias g=git
alias s=systemctl
alias d=docker
alias ls='ls --color=auto'
alias l='ls -lhs'
alias ll=l
alias tg='telegram-cli -N'
alias sudo='sudo '
alias man=vman
alias x='xdg-open'
alias weather='curl wttr.in/hamburg'
function sg { surfraw google "$@";}

# These files will be ignored for autocompletion
export FIGNORE=.swp:.swo:.git

## This part is stolen: https://github.com/mrzool/bash-sensible/blob/master/sensible.bash
# Update window size after every command
shopt -s checkwinsize

# Automatically trim long paths in the prompt (requires Bash 4.x)
PROMPT_DIRTRIM=2

# Perform file completion in a case insensitive fashion
bind "set completion-ignore-case on"

# Display matches for ambiguous patterns at first tab press
bind "set show-all-if-ambiguous on"

# Append to the history file, don't overwrite it
shopt -s histappend

# Save multi-line commands as one command
shopt -s cmdhist

# Record each line as it gets issued
PROMPT_COMMAND='history -a'

# Huge history. Doesn't appear to slow things down, so why not?
HISTSIZE=500000
HISTFILESIZE=100000

# Avoid duplicate entries in history
HISTCONTROL="erasedups:ignoreboth"

# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear:l"

# Useful timestamp format
HISTTIMEFORMAT='%F %T '

# Enable incremental history search with up/down arrows (also Readline goodness)
# Learn more about this here: http://codeinthehole.com/writing/the-most-important-command-line-tip-incremental-history-searching-with-inputrc/
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\e[C": forward-char'
bind '"\e[D": backward-char'

# Correct spelling errors during tab-completion
shopt -s dirspell 
# Correct spelling errors in arguments supplied to cd
shopt -s cdspell 2> /dev/null

## STolen part end

# Functions
function mkcd {
  if [ ! -n "$1" ]; then
    echo "Enter a directory name"
  elif [ -e $1 ]; then
    echo "\`$1' already exists"
  else
    mkdir $1 && cd $1
  fi
}

gal() {
  git add --all
  git diff HEAD
}

macTo6() {
  IFS=':'; set ${1,,}; unset IFS
   echo "fe80::$(printf %02x $((0x$1 ^ 2)))$2:${3}ff:fe$4:$5$6"
}

function vman() {
  vim -c "SuperMan $*"
  if [ "$?" != "0" ]; then
    echo "No manual entry for $*"
  fi
}

# Prompt
## Functions
printGitBranch() {
  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ ! -z "$branch" ]]; then
    echo "[${branch}]"
  fi
}
printBackgroundJobs() {
  local jobs=$(jobs|tail -1|cut -c2 2>/dev/null)
  if [[ ! -z "$jobs" ]]; then
    echo "[${jobs}]"
  fi

}
## Colored Strings..Ugly as fk
userString="\[\033[38;5;10m\]\u\[$(tput sgr0)\]"
hostnameString="\[\033[38;5;14m\]\h\[$(tput sgr0)\]"
timeString="\[\033[38;5;12m\][\$(date +%F-%H:%M)]\[$(tput sgr0)\]"
branchString="\[\033[38;5;11m\]\$(printGitBranch)\[$(tput sgr0)\]"
dirString='\[\033[38;5;13m\]\w\[$(tput sgr0)\]'
dollarString='\[\033[38;5;9m\]\\$\[$(tput sgr0)\]'
jobsString="\[\033[38;5;9m\]\$(printBackgroundJobs)\[$(tput sgr0)\]"

## Prompt!
PS1="${userString}@${hostnameString}-${timeString}:${branchString}${jobsString}${dirString}\n${dollarString} "

function alias_completion {
    local namespace="alias_completion"

    # parse function based completion definitions, where capture group 2 => function and 3 => trigger
    local compl_regex='complete( +[^ ]+)* -F ([^ ]+) ("[^"]+"|[^ ]+)'
    # parse alias definitions, where capture group 1 => trigger, 2 => command, 3 => command arguments
    local alias_regex="alias ([^=]+)='(\"[^\"]+\"|[^ ]+)(( +[^ ]+)*)'"

    # create array of function completion triggers, keeping multi-word triggers together
    eval "local completions=($(complete -p | sed -Ene "/$compl_regex/s//'\3'/p"))"
    (( ${#completions[@]} == 0 )) && return 0

    # create temporary file for wrapper functions and completions
    rm -f "/tmp/${namespace}-*.tmp" # preliminary cleanup
    local tmp_file; tmp_file="$(mktemp "/tmp/${namespace}-${RANDOM}XXX.tmp")" || return 1

    local completion_loader; completion_loader="$(complete -p -D 2>/dev/null | sed -Ene 's/.* -F ([^ ]*).*/\1/p')"

    # read in "<alias> '<aliased command>' '<command args>'" lines from defined aliases
    local line; while read line; do
        eval "local alias_tokens; alias_tokens=($line)" 2>/dev/null || continue # some alias arg patterns cause an eval parse error
        local alias_name="${alias_tokens[0]}" alias_cmd="${alias_tokens[1]}" alias_args="${alias_tokens[2]# }"

        # skip aliases to pipes, boolean control structures and other command lists
        # (leveraging that eval errs out if $alias_args contains unquoted shell metacharacters)
        eval "local alias_arg_words; alias_arg_words=($alias_args)" 2>/dev/null || continue
        # avoid expanding wildcards
        read -a alias_arg_words <<< "$alias_args"

        # skip alias if there is no completion function triggered by the aliased command
        if [[ ! " ${completions[*]} " =~ " $alias_cmd " ]]; then
            if [[ -n "$completion_loader" ]]; then
                # force loading of completions for the aliased command
                eval "$completion_loader $alias_cmd"
                # 124 means completion loader was successful
                [[ $? -eq 124 ]] || continue
                completions+=($alias_cmd)
            else
                continue
            fi
        fi
        local new_completion="$(complete -p "$alias_cmd")"

        # create a wrapper inserting the alias arguments if any
        if [[ -n $alias_args ]]; then
            local compl_func="${new_completion/#* -F /}"; compl_func="${compl_func%% *}"
            # avoid recursive call loops by ignoring our own functions
            if [[ "${compl_func#_$namespace::}" == $compl_func ]]; then
                local compl_wrapper="_${namespace}::${alias_name}"
                    echo "function $compl_wrapper {
                        (( COMP_CWORD += ${#alias_arg_words[@]} ))
                        COMP_WORDS=($alias_cmd $alias_args \${COMP_WORDS[@]:1})
                        (( COMP_POINT -= \${#COMP_LINE} ))
                        COMP_LINE=\${COMP_LINE/$alias_name/$alias_cmd $alias_args}
                        (( COMP_POINT += \${#COMP_LINE} ))
                        $compl_func
                    }" >> "$tmp_file"
                    new_completion="${new_completion/ -F $compl_func / -F $compl_wrapper }"
            fi
        fi

        # replace completion trigger by alias
        new_completion="${new_completion% *} $alias_name"
        echo "$new_completion" >> "$tmp_file"
    done < <(alias -p | sed -Ene "s/$alias_regex/\1 '\2' '\3'/p")
    source "$tmp_file" && rm -f "$tmp_file"
}; alias_completion
