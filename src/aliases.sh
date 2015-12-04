#!/bin/bash
##===============================================================================
## Copyright (c) 2013-2015 PoiXson, Mattsoft
## <http://poixson.com> <http://mattsoft.net>
##
## Description: Shell command aliases and shortcuts.
##
## Install to location: /usr/bin/shellscripts
##
## Download the original from:
##   http://dl.poixson.com/shellscripts/
##
## Permission to use, copy, modify, and/or distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
##
## THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
## OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
##===============================================================================
# aliases.sh


# cd aliases
alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'


# exit/kill aliases
alias e='exit'
alias killall='killall -v'
alias k='killall'
alias c='clear'
alias kk='konsole && exit $?'
#alias kon='konsole -e su &'


# file aliases
alias rm='rm -v -i --preserve-root'
alias cp='cp -v -i'
alias mv='mv -v -i'
alias cwd='pwd'
alias ccat='clear;cat'
alias untar='tar -zxvf'
alias scp='scp -C'


# list file aliases
alias ls='ls -A --color=auto'
alias ll='ls -lhs'

alias ls.='ls -d .*'
alias ll.='ll -d .*'
alias ld='ll -d */'
alias l.='ll.'

alias cls='clear;pwd;ls'
alias cll='clear;pwd;ll'
alias cld='clear;pwd;ld'

# sort by extension
alias lx='ls -lXB'
# sort by size
alias lk='ls -lSr'


# ch-permission aliases
alias chmod='chmod -v --preserve-root'
alias chown='chown -v --preserve-root'
alias chgrp='chgrp -v --preserve-root'


# parse aliases
alias grep='grep --color=auto'
alias diff='colordiff'


# date/time aliases
alias timenow='date +"%T"'
alias datenow='date +"%Y-%m-%d"'
alias datetime='date +"%Y-%m-%d %T"'
alias dayofyear='date +"%j"'


# watch aliases
alias W='watch'
alias wfast='watch -n0.2'
alias ww='watch w'
alias memtop='watch -d "free -m;echo;ps aux --sort -rss | head -11"'
alias vtop='virt-top -d 1'
alias httpw='watch -d -n1 /usr/bin/lynx -dump -width 500 http://127.0.0.1/whm-server-status'
alias wdd="watch -n5 kill -USR1 `pgrep -l '^dd$' | awk '{ print $1 }'`"
alias wtime='watch -n0.2 date'


# disk space aliases
alias df='df -h'
alias dfi='df -i'
alias wdf='watch -d -n1 "df -h;echo;df -i"'
alias cdu='clear;du -sch *'
alias du1='du -h --max-depth=1'
alias du2='du -h --max-depth=2'
alias du3='du -h --max-depth=3'


# screen aliases
alias screena='screen -x'
alias screenc='screen -mS'


# yum aliases
alias yumy='yum -y'
alias yumup='yum clean all && clear && yum update'
alias yumupy='yumup -y'


# more tools
alias hist='clear;history | grep $1'
alias psaux='ps auxf'
alias header='curl -I'
# alias ports='netstat -tulanp'
alias ports='netstat -nape --inet'


# iptables aliases
alias fwl='iptables -L -v'
alias fwf='iptables -F;iptables -P INPUT ACCEPT;iptables -P OUTPUT ACCEPT;iptables -P FORWARD ACCEPT'


# development
alias countlines='find . -name "*.java" | xargs wc -l'
alias mvnv='mvn versions:display-dependency-updates'
alias gem='gem -V'


# git aliases
alias gg='/usr/libexec/git-core/git-gui'
alias gge='gg && exit $?'
alias gits='clear;git status'
alias gitm='git mergetool'


# gradle aliases
alias g='clear;gradle --daemon'
alias ge='clear;gradle --daemon cleanEclipse eclipse'


# iscsi tools
#http://www.server-world.info/en/note?os=Fedora_20&p=iscsi
alias lstgt='clear;tgtadm --mode target --op show'


# zfs aliases
alias z='zpool iostat -v 2>&1 | sed "/^\s*$/d" ; zpool status 2>&1 | sed "/^\s*$/d" | grep -v errors\:\ No\ known\ data\ errors ; echo ; df -h ; zfs get compressratio 2>&1 | grep --invert-match --color=none 1.00'
alias wz='watch "zpool iostat -v 2>&1 | sed \"/^\s*$/d\" ; zpool status 2>&1 | sed \"/^\\s*$/d\" | grep -v \"errors: No known data errors\" ; echo ; df -h ; zfs get compressratio 2>&1 | grep --invert-match --color=none 1.00"'
# snapshot aliases
alias snapshots='clear;zfs list -t snapshot'
alias snaps='snapshots'
alias wsnaps='watch -d -n10 "snapshots;echo;df -h"'
alias wsnap='wsnaps'


# shutdown/reboot
alias reboot='yesno.sh "Reboot?" --timeout 10 --default y && shutdown -r now'
alias stop='yesno.sh "Shutdown?" --timeout 10 --default y && shutdown -h now'
