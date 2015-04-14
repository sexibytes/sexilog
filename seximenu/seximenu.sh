#!/bin/bash
#
# SexiLog Configure Tool
# Version 20150115
#
# Copyright (C) 2015  http://www.sexilog.fr
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Based on EFA-project configuration tool
# http://efa-project.org/
# 

# Enable Extended Globs
shopt -s extglob

# Display menus
show_menu() {
  menu=1
  while [ $menu == "1" ]; do
    func_echo-header
    echo -e "Please choose an option:"
    echo -e " "
    echo -e "0) Logout                              5)$cyan Network settings$clean"
    echo -e "1) Shell                               6)$cyan Change console keymap (for Frenchies)$clean"
    echo -e "2)$yellow Reboot system$clean                       7)$cyan Riemann (e-mail) settings$clean"
    echo -e "3)$yellow Halt system$clean"
    echo -e "4)$yellow Restart SexiLog services$clean"
    echo -e ""
    echo -e -n "$green[SEXILOG]$clean : "
    local choice
    read choice
    case $choice in
      0) clear; SSHPID=`ps aux | egrep "sshd: [a-zA-Z]+@" | awk {' print $2 '}`; kill $SSHPID; CONSPID=`ps aux | egrep "tty1.*/bin/login" | grep -v egrep | awk {' print $2 '}`; kill $CONSPID ;;
      1) exit 0 ;;
      2) func_reboot ;;
      3) func_halt ;;
      4) func_restartservices ;;
      5) func_networksettings ;;
      6) func_keymap ;;
      7) func_riemann ;;
      *) echo -e "Error \"$choice\" is not an option..." && sleep 2
    esac
  done
}

# Reboot function
func_reboot() {
  menu=0
  rebootmenu=1
  while [ $rebootmenu == "1" ]; do
    func_echo-header
    echo -e "Are you sure you want to reboot this host?"
    echo -e ""
    echo -e "Y)  Yes I am sure"
    echo -e "N)  No no no take me back!"
    echo -e ""
    echo -e -n "$green[SEXILOG]$clean : "
    local choice
    read choice
    case $choice in
      Y) reboot && exit 0 ;;
      N) menu=1 && return  ;;
      n) menu=1 && return  ;;
      *) echo -e "Error \"$choice\" is not an option..." && sleep 2
    esac
  done
}

# Restart SexiLog services function
func_restartservices() {
  func_echo-header
  echo -e ""
  echo -e "$red Restarting SexiLog services will restart:"
  echo -e "                     /etc/init.d/riemann"
  echo -e "                     /etc/init.d/logstash"
  echo -e "                     /etc/init.d/elasticsearch"
  echo -e "                     /etc/init.d/node-app"
  echo -e "                     /etc/init.d/rsyslog"
  echo -e ""
  echo -e -n "Are you sure you want to restart SexiLog services? (y/N): $clean"

  local TMPYN
  read TMPYN
  if [[ $TMPYN == "y" || $TMPYN == "Y" ]]; then
    /etc/init.d/riemann stop
    /etc/init.d/logstash stop
    /etc/init.d/elasticsearch stop
    /etc/init.d/elasticsearch start
    /etc/init.d/riemann start
    /etc/init.d/logstash start
    /etc/init.d/node-app restart --force
    /etc/init.d/rsyslog restart
    echo -e ""
    echo -e "SexiLog services restarted"
    echo -e ""
    pause
  else
    echo -e "No changes made"
    pause
  fi
}

# Change keymap function
func_keymap() {
  func_echo-header
  kblayout=`grep XKBLAYOUT /etc/default/keyboard`
  kblayout=${kblayout##*=}
  echo -e ""
  echo -e "$yellow Current keymap layout is: "`echo $kblayout`
  echo -e ""
  if [[ $kblayout == "\"us\"" ]]; then
    echo -e -n "$clean Do you want to switch to 'fr' layout? (y/N):"
    changelayout="fr"
  else
    echo -e -n "$clean Do you want to switch to 'us' layout? (y/N):"
    changelayout="us"
  fi

  local TMPYN
  read TMPYN
  if [[ $TMPYN == "y" || $TMPYN == "Y" ]]; then
    sed -i "s/XKBLAYOUT=.*$/XKBLAYOUT=\"`echo $changelayout`\"/g" /etc/default/keyboard
    service keyboard-setup restart
    echo -e ""
    echo -e "Default keymap layout have been updated to "`echo $changelayout`
    echo -e ""
    pause
  else
    echo -e "No changes made"
    pause
  fi
}

# Halt function
func_halt() {
  menu=0
  haltmenu=1
  while [ $haltmenu == "1" ]; do
    func_echo-header
    echo -e "Are you sure you want to halt this host?"
    echo -e ""
    echo -e "Y)  Yes I am sure"
    echo -e "N)  No no no take me back!"
    echo -e ""
    echo -e -n "$green[SEXILOG]$clean : "
    local choice
    read choice
    case $choice in
      Y) shutdown -h now && exit 0 ;;
      N) menu=1 && return  ;;
      n) menu=1 && return  ;;
      *) echo -e "Error \"$choice\" is not an option..." && sleep 2
    esac
  done
}

# Network configuration
func_networksettings() {
  func_echo-header
  echo -e " Network configuration"
  echo -e ""
  echo -e -n "Do you want to configure your network with DHCP for this machine? (y/N): "
  local TMPYN
  read TMPYN
  if [[ $TMPYN == "y" || $TMPYN == "Y" ]]; then
    echo -e "auto lo" > /etc/network/interfaces
    echo -e "iface lo inet loopback" >> /etc/network/interfaces
    echo -e "allow-hotplug eth0" >> /etc/network/interfaces
    echo -e "iface eth0 inet dhcp" >> /etc/network/interfaces
    echo -e ""
    echo -e "DHCP enabled"
    echo -e ""
    echo -e "$red [SEXILOG] Your system will now reboot. $clean"
    pause
    reboot
    exit
  elif [[ $TMPSECURE == "n" || $TMPSECURE == "N" || $TMPSECURE="" ]]; then
    # IP
    inputip=""
    validcheck=1
    while [ $validcheck != "0" ]; do
      if checkip $inputip; then
        validcheck=0
      else
        func_echo-header
        echo -e " Network configuration [STEP 1/5]"
        echo -e ""
        echo -e " Settings to be applied"
        echo -e " IP:       N/A"
        echo -e " Netmask:  N/A"
        echo -e " Gateway:  N/A"
        echo -e " DNS:      N/A"
        echo -e " Hostname: N/A"
        echo -e ""
        echo -e "$green[SEXILOG]$clean Please provide new IP address for SexiLog appliance"
        echo -e -n "('q' to quit wizard): "
        read inputip
        if [[ $inputip == "q" ]]; then
          return
        fi
      fi
    done
    # Netmask
    inputnm=""
    validcheck=1
    while [ $validcheck != "0" ]; do
      if checkip $inputnm; then
        validcheck=0
      else
        func_echo-header
        echo -e " Network configuration [STEP 2/5]"
        echo -e ""
        echo -e " Settings to be applied"
        echo -e " IP:       $inputip"
        echo -e " Netmask:  N/A"
        echo -e " Gateway:  N/A"
        echo -e " DNS:      N/A"
        echo -e " Hostname: N/A"
        echo -e ""
        echo -e "$green[SEXILOG]$clean Please provide new netmask address for SexiLog appliance"
        echo -e -n "('q' to quit wizard) (###.###.###.###): "
        read inputnm
        if [[ $inputnm == "q" ]]; then
          return
        fi
      fi
    done
    # Gateway
    inputgw=""
    validcheck=1
    while [ $validcheck != "0" ]; do
      if checkip $inputgw; then
        validcheck=0
      else
        func_echo-header
        echo -e " Network configuration [STEP 3/5]"
        echo -e ""
        echo -e " Settings to be applied"
        echo -e " IP:       $inputip"
        echo -e " Netmask:  $inputnm"
        echo -e " Gateway:  N/A"
        echo -e " DNS:      N/A"
        echo -e " Hostname: N/A"
        echo -e ""
        echo -e "$green[SEXILOG]$clean Please provide new gateway address for SexiLog appliance"
        echo -e -n "('q' to quit wizard): "
        read inputgw
        if [[ $inputgw == "q" ]]; then
          return
        fi
      fi
    done
    # DNS
    inputdns=""
    validcheck=1
    while [ $validcheck != "0" ]; do
      if checkip $inputdns; then
        validcheck=0
      else
        func_echo-header
        echo -e " Network configuration [STEP 4/5]"
        echo -e ""
        echo -e " Settings to be applied"
        echo -e " IP:       $inputip"
        echo -e " Netmask:  $inputnm"
        echo -e " Gateway:  $inputgw"
        echo -e " DNS:      N/A"
        echo -e " Hostname: N/A"
        echo -e ""
        echo -e "$green[SEXILOG]$clean Please provide new DNS address for SexiLog appliance (only one DNS server)"
        echo -e -n "('q' to quit wizard): "
        read inputdns
        if [[ $inputdns == "q" ]]; then
          return
        fi
      fi
    done
    # Hostname
    inputhostname=""
    validcheck=1
    while [ $validcheck != "0" ]; do
      if [[ $inputhostname =~ ^[-a-zA-Z0-9_.]{2,256}+$ ]]; then
        validcheck=0
      else
        func_echo-header
        echo -e " Network configuration [STEP 5/5]"
        echo -e ""
        echo -e " Settings to be applied"
        echo -e " IP:       $inputip"
        echo -e " Netmask:  $inputnm"
        echo -e " Gateway:  $inputgw"
        echo -e " DNS:      $inputdns"
        echo -e " Hostname: N/A"
        echo -e ""
        echo -e "$green[SEXILOG]$clean Please provide new hostname for SexiLog appliance"
        echo -e -n "('q' to quit wizard): "
        read inputhostname
        if [[ $inputhostname == "q" ]]; then
          return
        fi
      fi
    done
    func_echo-header
    echo -e " Network configuration"
    echo -e "$yellow Here are settings that will be applied:"
    echo -e ""
    echo -e " IP:       $inputip"
    echo -e " Netmask:  $inputnm"
    echo -e " Gateway:  $inputgw"
    echo -e " DNS:      $inputdns"
    echo -e " Hostname: $inputhostname"
    echo -e "$clean"
    echo -e "$red Updating your network settings will reboot your appliance.$clean"
    echo -e ""
    echo -e -n "Are you sure you want to update network settings of this machine? (y/N): "

    local TMPYN
    read TMPYN
    if [[ $TMPYN == "y" || $TMPYN == "Y" ]]; then
      # Set ip settings
      echo "auto lo" > /etc/network/interfaces
      echo "iface lo inet loopback" >> /etc/network/interfaces
      echo "allow-hotplug eth0" >> /etc/network/interfaces
      echo "iface eth0 inet static" >> /etc/network/interfaces
      echo " address $inputip" >> /etc/network/interfaces
      echo " netmask $inputnm" >> /etc/network/interfaces
      echo " gateway $inputgw" >> /etc/network/interfaces
      echo " dns-nameservers $inputdns" >> /etc/network/interfaces

      # Write new hosts file
      echo "127.0.0.1   localhost" > /etc/hosts
      echo "$inputip   $inputhostname" >> /etc/hosts
      echo "$inputhostname" > /etc/hostname

      # Set the hostname for the active system
      hostname $HOSTNAME
      echo -e ""
      echo -e "New network settings applied"
      echo -e ""
      echo -e "$red [SEXILOG] Your system will now reboot. $clean"
      pause
      reboot
      exit
    elif [[ $TMPSECURE == "n" || $TMPSECURE == "N" || $TMPSECURE="" ]]; then
      echo -e "No changes made"
      pause
      ipmenu=1
    fi
  fi
}

# Riemann configuration
func_riemann() {
  func_echo-header
  echo -e " Riemann current configuration:"
  echo -e "$yellow"
  echo -e " SMTP:     "`cat /etc/riemann/riemann.config | grep 'str "\["' | sed 's/.* :host "\(.*\)\" :subject.*/\1/'`
  echo -e " From:     "`cat /etc/riemann/riemann.config | grep 'str "\["' | sed 's/.* :from "\(.*\)\" :host.*/\1/'`
  echo -e " To:       "`cat /etc/riemann/riemann.config | grep -Po '(?<=    \(emailp ").*(?="\))'`
  echo -e ""
  echo -e -n "$clean Do you want to update these riemann settings on this machine? (y/N): "

  local TMPYN
  read TMPYN
  if [[ $TMPYN == "y" || $TMPYN == "Y" ]]; then
    inputip=""
    validcheck=1
    while [ $validcheck != "0" ]; do
      if checkip $inputip; then
        validcheck=0
      else
        func_echo-header
        echo -e " Riemann configuration [STEP 1/3]"
        echo -e ""
        echo -e "$green[SEXILOG]$clean What is the IP address of your SMTP server"
        echo -e -n "('q' to quit wizard): "
        read inputip
        if [[ $inputip == "q" ]]; then
          return
        fi
      fi
    done

    # Check if the sender email is valid
    inputfrommail=""
    sendercheck=1
    while [ $sendercheck != 0 ]; do
      if [[ $inputfrommail =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        sendercheck=0
      else
        func_echo-header
        echo -e " Riemann configuration [STEP 2/3]"
        echo -e ""
        echo -e "$green[SEXILOG]$clean What is the sender email Riemann could use"
        echo -e -n "('q' to quit wizard) (like sender@domain.tld): "
        read inputfrommail
        if [[ $inputfrommail == "q" ]]; then
          return
        fi
      fi
    done

    # Check if the recipient email is valid
    inputtomail=""
    recipientcheck=1
    while [ $recipientcheck != 0 ]; do
      if [[ $inputtomail =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        recipientcheck=0
      else
        func_echo-header
        echo -e " Riemann configuration [STEP 3/3]"
        echo -e ""
        echo -e "$green[SEXILOG]$clean What is the recipient email Riemann could use"
        echo -e -n "('q' to quit wizard) (like recipient@domain.tld): "
        read inputtomail
        if [[ $inputtomail == "q" ]]; then
          return
        fi
      fi
    done
    
    func_echo-header
    echo -e " Here are settings that will be applied:\n"
    echo -e " SMTP server IP:       $inputip"
    echo -e " From mail address:    $inputfrommail"
    echo -e " To mail address:      $inputtomail"
    echo -e ""
    echo -e "$red Updating your Riemann settings will restart /etc/init.d/riemann $clean"
    echo -e ""
    echo -e -n "Are you sure you want to update riemann settings of this machine? (y/N): "

    local TMPYN
    read TMPYN
    if [[ $TMPYN == "y" || $TMPYN == "Y" ]]; then
      sed -e "s/%IP%/$inputip/" -e "s/%EMAIL_FROM%/$inputfrommail/" -e "s/%EMAIL_TO%/$inputtomail/" /root/seximenu/conf/riemann.config.sample > /root/seximenu/conf/riemann.config
      cp -f /root/seximenu/conf/riemann.config /etc/riemann/riemann.config
      rm -f /root/seximenu/conf/riemann.config
      echo -e ""
      echo -e "Riemann settings updated   [$green OK $clean]"
      echo -e ""
      echo -e "$red [SEXILOG] Restarting /etc/init.d/riemann$clean\n"
      pause
      /etc/init.d/riemann restart
      pause
    elif [[ $TMPSECURE == "n" || $TMPSECURE == "N" || $TMPSECURE="" ]]; then
      echo -e "No changes made"
      pause
      ipmenu=1
    fi
  elif [[ $TMPSECURE == "n" || $TMPSECURE == "N" || $TMPSECURE="" ]]; then
    echo -e "No changes made"
    pause
    ipmenu=1
  fi
}

# Function to test IP addresses
function checkip(){
  local ip=$1
  local stat=1

  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}

# Trap CTRL+C, CTRL+Z and quit singles
trap '' SIGINT SIGQUIT SIGTSTP

# Pause
pause(){
  read -p "Press [Enter] key to continue..." fackEnterKey
}

# Menu header
func_echo-header(){
  stateriemann=`/etc/init.d/riemann status`
  statelogstash=`/etc/init.d/logstash status`
  stateelasticsearch=`/etc/init.d/elasticsearch status`
  statenodeapp=`/etc/init.d/node-app status`
  clear                                                           
  echo ""
  echo -e "      _/_/_/                      _/  _/                            "
  echo -e "   _/          _/_/    _/    _/      _/          _/_/      _/_/_/   "
  echo -e "    _/_/    _/_/_/_/    _/_/    _/  _/        _/    _/  _/    _/    "
  echo -e "       _/  _/        _/    _/  _/  _/        _/    _/  _/    _/     "
  echo -e "_/_/_/      _/_/_/  _/    _/  _/  _/_/_/_/    _/_/      _/_/_/      "
  echo -e "                                                           _/       "
  echo -e "                                                      _/_/          "
  # echo -e " ______     ______     __  __     __     __         ______     ______    "
  # echo -e "/\  ___\   /\  ___\   /\_\_\_\   /\ \   /\ \       /\  __ \   /\  ___\   "
  # echo -e "\ \___  \  \ \  __\   \/_/\_\/_  \ \ \  \ \ \____  \ \ \/\ \  \ \ \__ \  "
  # echo -e " \/\_____\  \ \_____\   /\_\/\_\  \ \_\  \ \_____\  \ \_____\  \ \_____\ "
  # echo -e "  \/_____/   \/_____/   \/_/\/_/   \/_/   \/_____/   \/_____/   \/_____/ "
  # echo -e "                                                                         "
  echo ""
  echo -e "Hostname:    `hostname`"
  echo -e "IP:          `ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*'`"
  echo -e "Netmask:     `ifconfig eth0 | grep -Eo ' (Mask:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*'`"
  echo -e "GW:          "`ip route show | grep -Eo "default via ([0-9]*\.){3}[0-9]*" | grep -Eo '([0-9]*\.){3}[0-9]*'`""
  echo ""
  echo -e "`df -h | egrep "Filesystem|rootfs|sexilog" | sed -e "s/                                  //"`"
  echo ""
  if [[ $stateelasticsearch =~ "is running" ]]; then
    echo -e -n " elasticsearch [$green RUNNING $clean]"
  else
    echo -e -n " elasticsearch [$red FAILED  $clean]"
  fi
  if [[ $stateriemann =~ "is running" ]]; then
    echo -e "              riemann       [$green RUNNING $clean]"
  else
    echo -e "              riemann       [$red FAILED  $clean]"
  fi
  if [[ $statelogstash =~ "is running" ]]; then
    echo -e -n " logstash      [$green RUNNING $clean]"
  else
    echo -e -n " logstash      [$red FAILED  $clean]"
  fi
  if [[ $statenodeapp =~ "Node app running with pid" ]]; then
    echo -e "              node-app      [$green RUNNING $clean]"
  else
    echo -e "              node-app      [$red FAILED  $clean]"
  fi
  echo ""
  echo -e "===================================================================="
  echo ""
}

# Main logic
clear
red='\E[00;31m'
green='\E[00;32m'
yellow='\E[00;33m'
blue='\E[00;34m'
magenta='\E[00;35m'
cyan='\E[00;36m'
clean='\e[00m'

if [ `whoami` == root ]; then
  menu="1"
  while [ $menu == "1" ]; do
    show_menu
  done
else
  echo -e "$red [SEXILOG] ERROR: Please become root.$clean"
  exit 0
fi