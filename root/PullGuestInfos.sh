#!/bin/bash

GUESTINFO=$(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv"|xml_grep 'Kind' --text_only)

if [[ $GUESTINFO =~ "VMware ESXi" ]]; then

  GUESTIP=$(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv"|grep guestinfo.ipaddress|awk -F'"' '{ print $4 }')
  GUESTMASK=$(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv"|grep guestinfo.netmask|awk -F'"' '{ print $4 }')
  GUESTGW=$(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv"|grep guestinfo.gateway|awk -F'"' '{ print $4 }')

  if [[ $GUESTIP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] && [[ $GUESTMASK =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] && [[ $GUESTGW =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then

    GUESTNS=$(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv"|grep guestinfo.dns|awk -F'"' '{ print $4 }')
    GUESTDNS=$(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv"|grep guestinfo.domain|awk -F'"' '{ print $4 }')
    GUESTNAME=$(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv"|grep guestinfo.hostname|awk -F'"' '{ print $4 }')

    echo "auto lo" > /tmp/tmp-interfaces
    echo "iface lo inet loopback" >> /tmp/tmp-interfaces
    echo "allow-hotplug eth0" >> /tmp/tmp-interfaces
    echo "iface eth0 inet static" >> /tmp/tmp-interfaces
    echo " address $GUESTIP" >> /tmp/tmp-interfaces
    echo " netmask $GUESTMASK" >> /tmp/tmp-interfaces
    echo " gateway $GUESTGW" >> /tmp/tmp-interfaces

    if [[ $GUESTNS =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
    	echo " dns-nameservers $GUESTNS" >> /tmp/tmp-interfaces
    fi

    if [[ -n $GUESTDNS ]]; then
    	echo " dns-search $GUESTDNS" >> /tmp/tmp-interfaces
    fi

    if cmp -s "/tmp/tmp-interfaces" "/etc/network/interfaces"; then
      rm -f /tmp/tmp-interfaces
    else
      cp -f /tmp/tmp-interfaces /etc/network/interfaces
      needUpdate=true
    fi

    echo "127.0.0.1   localhost" > /tmp/tmp-hosts
    echo "$GUESTIP   $GUESTNAME" >> /tmp/tmp-hosts

    if cmp -s "/tmp/tmp-hosts" "/etc/hosts"; then
      rm -f /tmp/tmp-hosts
    else
      cp -f /tmp/tmp-hosts /etc/hosts
      needUpdate=true
    fi

    echo "$GUESTNAME" > /tmp/tmp-hostname

    if cmp -s "/tmp/tmp-hostname" "/etc/hostname"; then
      rm -f /tmp/tmp-hostname
    else
      cp -f /tmp/tmp-hostname /etc/hostname
      needUpdate=true
    fi

    if [[ $needUpdate ]]; then
      hostname $GUESTNAME
      /etc/init.d/networking stop && /etc/init.d/networking start
      /etc/init.d/resolvconf stop && /etc/init.d/resolvconf start

      ifdown eth0 && ifup eth0
    fi
  fi

fi
