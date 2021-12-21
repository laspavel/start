# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# ########## MY CONFIGURATION ############

# ######### FUNCTION #########

if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

ipinfo() { curl ipinfo.io/$1; echo "";} 

c() { echo $1 | bc -l;} 

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

ssh_search() { grep "$1" ~/.ssh/config ~/.ssh/config.d/* -A 7 -B 7;} 
alias sshhosts="grep -w -i -E 'Host|HostName' ~/.ssh/config ~/.ssh/config.d/* | sed 's/Host //' | sed 's/HostName //'"

## load ssh autocompletion
_ssh() 
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts=$(grep '^Host' ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null | grep -v '[?*]' | cut -d ' ' -f 2-)

  COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
  return 0
}

complete -F _ssh ssh

ssh() {
  tmux rename-window "$*"
  command ssh "$@"
  tmux rename-window "bash"
}

md5(){ echo -n "$1" | md5sum; }

function pfx2crt() {
    fbname=$(basename "$1" .pfx)
    openssl pkcs12 -in $fbname.pfx -clcerts -nokeys -out $fbname.crt
    openssl pkcs12 -in $fbname.pfx -nocerts -out $fbname-encrypt.key
    openssl rsa -in $fbname-encrypt.key -out $fbname.key
    rm -f $fbname-encrypt.key
}

# ######### COLOR #########

TERM=xterm-256color

# Forground
Default="\[\e[0m\]"

Black="\[\e[30m\]"
Blue="\[\e[34m\]"
Cyan="\[\e[36m\]"
DarkGray="\[\e[90m\]"
Gray="\[\e[37m\]"
Green="\[\e[32m\]"
LightBlue="\[\e[94m\]"
LightCyan="\[\e[96m\]"
LightGreen="\[\e[92m\]"
LightMajenta="\[\e[95m\]"
LightRed="\[\e[91m\]"
LightYellow="\[\e[93m\]"
Majenta="\[\e[35m\]"
Red="\[\e[31m\]"
White="\[\e[97m\]"
Yellow="\[\e[33m\]"

# Background
OnBlack="\[\e[40m\]"
OnBlue="\[\e[44m\]"
OnCyan="\[\e[46m\]"
OnDarkGray="\[\e[100m\]"
OnGreen="\[\e[42m\]"
OnLightBlue="\[\e[104m\]"
OnLightCyan="\[\e[106m\]"
OnLightGray="\[\e[47m\]"
OnLightGreen="\[\e[102m\]"
OnLightMajenta="\[\e[105m\]"
OnLightRed="\[\e[101m\]"
OnLightYellow="\[\e[103m\]"
OnMajenta="\[\e[45m\]"
OnRed="\[\e[41m\]"
OnWhite="\[\e[107m\]"
OnYellow="\[\e[43m\]"

# Reset
ColorOff="$Default"

# Reset
Color_Off="\[\033[0m\]"       # Text Reset

# Regular Colors
Black="\[\033[0;30m\]"        # Black
Red="\[\033[0;31m\]"          # Red
Green="\[\033[0;32m\]"        # Green
Yellow="\[\033[0;33m\]"       # Yellow
Blue="\[\033[0;34m\]"         # Blue
Purple="\[\033[0;35m\]"       # Purple
Cyan="\[\033[0;36m\]"         # Cyan
White="\[\033[0;37m\]"        # White

# Bold
BBlack="\[\033[1;30m\]"       # Black
BRed="\[\033[1;31m\]"         # Red
BGreen="\[\033[1;32m\]"       # Green
BYellow="\[\033[1;33m\]"      # Yellow
BBlue="\[\033[1;34m\]"        # Blue
BPurple="\[\033[1;35m\]"      # Purple
BCyan="\[\033[1;36m\]"        # Cyan
BWhite="\[\033[1;37m\]"       # White

# Underline
UBlack="\[\033[4;30m\]"       # Black
URed="\[\033[4;31m\]"         # Red
UGreen="\[\033[4;32m\]"       # Green
UYellow="\[\033[4;33m\]"      # Yellow
UBlue="\[\033[4;34m\]"        # Blue
UPurple="\[\033[4;35m\]"      # Purple
UCyan="\[\033[4;36m\]"        # Cyan
UWhite="\[\033[4;37m\]"       # White

# Background
On_Black="\[\033[40m\]"       # Black
On_Red="\[\033[41m\]"         # Red
On_Green="\[\033[42m\]"       # Green
On_Yellow="\[\033[43m\]"      # Yellow
On_Blue="\[\033[44m\]"        # Blue
On_Purple="\[\033[45m\]"      # Purple
On_Cyan="\[\033[46m\]"        # Cyan
On_White="\[\033[47m\]"       # White

# High Intensty
IBlack="\[\033[0;90m\]"       # Black
IRed="\[\033[0;91m\]"         # Red
IGreen="\[\033[0;92m\]"       # Green
IYellow="\[\033[0;93m\]"      # Yellow
IBlue="\[\033[0;94m\]"        # Blue
IPurple="\[\033[0;95m\]"      # Purple
ICyan="\[\033[0;96m\]"        # Cyan
IWhite="\[\033[0;97m\]"       # White

# Bold High Intensty
BIBlack="\[\033[1;90m\]"      # Black
BIRed="\[\033[1;91m\]"        # Red
BIGreen="\[\033[1;92m\]"      # Green
BIYellow="\[\033[1;93m\]"     # Yellow
BIBlue="\[\033[1;94m\]"       # Blue
BIPurple="\[\033[1;95m\]"     # Purple
BICyan="\[\033[1;96m\]"       # Cyan
BIWhite="\[\033[1;97m\]"      # White

# High Intensty backgrounds
On_IBlack="\[\033[0;100m\]"   # Black
On_IRed="\[\033[0;101m\]"     # Red
On_IGreen="\[\033[0;102m\]"   # Green
On_IYellow="\[\033[0;103m\]"  # Yellow
On_IBlue="\[\033[0;104m\]"    # Blue
On_IPurple="\[\033[10;95m\]"  # Purple
On_ICyan="\[\033[0;106m\]"    # Cyan
On_IWhite="\[\033[0;107m\]"   # White

PS1="$BBlue\u@\h:$BRed\$(parse_git_branch)$Color_Off$BGreen\w$ $Color_Off"

if [[ $SSH_CLIENT ]]; then
  PS1="$BBlue\u@\h:$BRed\$(parse_git_branch)$Color_Off$BGreen\w$ $Color_Off"
fi

#PS1="\[\033[1;33;1;34m\]\u@\h:\[\e[91m\]\$(parse_git_branch)\[\e[00m\]\[\033[1;32m\]\w$ \[\033[0m\]\[\033[0m\]"
#PS1="\[\033[1;33;1;34m\]\u@\h:\[\033[1;32m\]\w$ \[\033[0m\]\[\033[0m\]"

if [ -f /usr/bin/grc ]; then
  alias cvs="grc --colour=auto cvs"
  alias diff="grc --colour=auto diff"
  alias esperanto="grc --colour=auto esperanto"
  alias gcc="grc --colour=auto gcc"
  alias irclog="grc --colour=auto irclog"
  alias ldap="grc --colour=auto ldap"
  alias log="grc --colour=auto log"
  alias netstat="grc --colour=auto netstat"
  alias ping="grc --colour=auto ping"
  alias proftpd="grc --colour=auto proftpd"
  alias traceroute="grc --colour=auto traceroute"
  alias wdiff="grc --colour=auto wdiff"
fi

# ######### ALIAS #########

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gl='ls | grep --color'
alias ..='cd ../'
alias ...='cd ../..'
alias m='mount '
alias u='fusermount -u '
alias f='file'
alias s='stat'
alias rm='rm -i'
alias n='nano '
alias vi='vim'
alias cls='clear'
alias r='reset'
alias df='df -h'
alias du='du -h'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mc='mc -x'
alias fff="watch -tn 0.2 '$1'"

# Estimate file space usage to maximum depth
alias du1="du -d 1"

alias free='free -h'
alias mkdir='mkdir -pv'
alias passgen="echo $(head -c 11 /dev/random | base64 | sed "s:[+=/]::g" | head -c 11)"
alias urldecode='python -c "import sys, os, urllib as ul; name = ul.unquote_plus(sys.argv[1]); print name; os.rename(sys.argv[1], name)"'
alias port='netstat -tulanp'
alias listen="lsof -P -i -n" 
alias now='date +%d.%m.%Y%n%T'

# Get top process eating memory
alias psmem="ps auxf | sort -nr -k 4"
alias psmem10="ps auxf | sort -nr -k 4 | head -10"

# Get top process eating cpu
alias pscpu="ps auxf | sort -nr -k 3"
alias pscpu10="ps auxf | sort -nr -k 3 | head -10"

# Gives you what is using the most space. Both directories and files. Varies on current directory
alias most='du -hsx * | sort -rh | head -10'

# Utils from Internet
alias winbox='wine64 ~/.wine/drive_c/winbox.exe'
alias pogoda="curl wttr.in/Dnepr"

#open vscode
alias v="code $1"

# list all "Host" and "HostName" lines, then remove the strings: "Host " and "HostName "
alias sshhosts="grep -w -i -E 'Host|HostName' ~/.ssh/config ~/.ssh/config.d/* | sed 's/Host //' | sed 's/HostName //'"

#Docker
alias ubuntu18='docker run -it --rm --hostname ubuntu18 -v $(pwd):/data -w /data ubuntu:18.04 /bin/bash'
alias ubuntu20='docker run -it --rm --hostname ubuntu20 -v $(pwd):/data -w /data ubuntu:20.04 /bin/bash'
alias debian9='docker run -it --rm --hostname debian9 -v $(pwd):/data -w /data debian:stretch /bin/bash'
alias debian10='docker run -it --rm --hostname debian10 -v $(pwd):/data -w /data debian:buster /bin/bash'
alias centos7='docker run -it --rm --hostname centos7 -v $(pwd):/data -w /data centos:7 /bin/bash'
alias centos8='docker run -it --rm --hostname centos8 -v $(pwd):/data -w /data centos:8 /bin/bash'
alias py3='docker run -it --rm --hostname py3 -v $(pwd):/data -w /data python:3 /bin/bash'
alias ctop='docker run --rm -ti --name=ctop --volume /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop:latest'

# Kubernetes
alias k="kubectl"
alias kx="kubectx"
alias kn="kubens"

# Git shortcuts
alias ga='git add '
alias gb='git branch'
alias gba='git branch -a'
alias gbru='git remote prune origin'
alias gbd='git branch -D'
alias gc='git commit -m'
alias gcl='git clone'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gclean='git fetch --prune'
alias gd='git diff'
alias gdi='git di'
alias gr='git rm'
alias gs='git status'
alias gss='git status -s'
alias gll='git log'
alias glg='git lg'
alias gull='git pull origin'
alias gush='git push origin'
alias gt='git checkout'
alias gtd='git checkout develop'
alias gm='git merge --no-ff'
alias grv='git remote -v'

source <(kubectl completion bash)
complete -F __start_kubectl k

# ######### EXPORT PARAMETERS ################
if [ -f /usr/bin/nano ]; then
    export EDITOR="nano"
#    export VISUAL="nano"
fi

if [ -f /usr/bin/code ]; then
    export VISUAL="code"
fi

export KUBECONFIG=/home/laspavel/.kubeconfig/kube_config.yml
#export KUBECONFIG=~/_Project/Ansible/RKE2-Playbooks/aspo1_rke2/plays/kube_config_config-cluster_rancher.yml:~/_Project/Ansible/RKE2-Playbooks/aspo2_rke2/plays/kube_config_config-cluster_rancher.yml:~/_Project/Ansible/RKE2-Playbooks/dev_rke2/plays/kube_config_config-cluster_rancher.yml:~/_Project/Ansible/RKE2-Playbooks/prod_rke2/plays/kube_config_config-cluster_rancher.yml:~/_Project/Ansible/RKE2-Playbooks/prod_rke2_efk/plays/kube_config_config-cluster_rancher.yml:~/_Project/Ansible/RKE2-Playbooks/res_rke2/plays/kube_config_config-cluster_rancher.yml
alias lens="/opt/lens/lens"

export HISTCONTROL=ignorespace   # leading space hides commands from history
export HISTFILESIZE=10000        # increase history file size (default is 500)
export HISTSIZE=30000
export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"
export HISTTIMEFORMAT="[%d.%m.%y %T] "
export HISTIGNORE="&:[bf]g:c:clear:history:exit:q:pwd:* --help"
export MANPAGER="less -X"   # Don't clear the screen after quitting a `man` page
export PYTHONIOENCODING="UTF-8"  # Make Python use UTF-8 encoding for output to stdin/stdout/stderr.
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND" # Save and reload history after each command finishes


####################################


