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



alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias e='exit'
alias killall='killall -v'
alias k='killall'

alias rm='rm -v -i --preserve-root'
alias cp='cp -v -i'
alias mv='mv -v -i'

alias chmod='chmod -v --preserve-root'
alias chown='chown -v --preserve-root'
alias chgrp='chgrp -v --preserve-root'

alias cwd='pwd'
alias c='clear'

alias grep='grep --color=auto'
alias diff='colordiff'

alias yumy='yum -y'
alias yumup='yum clean all && clear && yum update'
alias yumupy='yumup -y'



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


alias W='watch'
alias wf='watch -n0.2'
alias ww='watch w'
alias memtop='watch "free -m;echo;ps aux --sort -rss | head -11"'
alias vtop='virt-top -d 1'
alias httpw='watch -n1 /usr/bin/lynx -dump -width 500 http://127.0.0.1/whm-server-status'


# alias ports='netstat -tulanp'
alias ports='netstat -nape --inet'


alias df='df -h'
alias dfi='df -i'
alias wdf='watch -n1 "df -h;echo;df -i"'

alias cdu='clear;du -sch *'
alias du1='du -h --max-depth=1'


alias wz='watch "zpool iostat -v;zpool status;echo;df -h;zfs get compressratio|grep --invert-match --color=none 1.00"'
alias bmdisk='time dd if=/dev/zero of=$PWD/test.file bs=1M count=10000;ll $PWD/test.file;rm $PWD/test.file'
alias syncmem='sync;echo 3 > /proc/sys/vm/drop_caches'

alias snapshots='clear;zfs list -t snapshot'
alias snaps='snapshots'
alias wsnaps='watch -n10 "snapshots;echo;df -h"'
alias wsnap='wsnaps'



alias screena='screen -x'
alias screenc='screen -mS'



alias countlines='find . -name "*.java" | xargs wc -l'

alias gg='/usr/libexec/git-core/git-gui'
alias gge='gg && exit $?'
alias gits='clear;git status'
alias gitm='git mergetool'

alias mvnv='mvn versions:display-dependency-updates'



alias kk='konsole && exit $?'

alias header='curl -I'



alias now='date +"%T"'
alias nowdate='date +"%Y-%m%d"'


alias gem='gem -V'

alias hist='clear;history | grep $1'

alias psaux='ps auxf'

alias untar='tar -zxvf'

alias sux='xterm -fn 7x14 -bg DarkOrange4 -fg white -e su &'
alias kon='konsole -e su &'

alias reboot='yesno.sh "Reboot?" --timeout 10 --default y && shutdown -r now'

