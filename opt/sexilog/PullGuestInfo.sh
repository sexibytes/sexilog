#!/bin/bash
#
GUESTINFO=$(xml_grep 'Kind' <(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv") --text_only)

if [[ $GUESTINFO =~ "VMware ESXi" ]]; then

        GUESTIP=$(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv"|grep guestinfo.ipaddress|awk -F'"' '{ print $4 }')
        GUESTMASK=$(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv"|grep guestinfo.netmask|awk -F'"' '{ print $4 }')
        GUESTGW=$(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv"|grep guestinfo.gateway|awk -F'"' '{ print $4 }')		

        if [[ $GUESTIP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] && [[ $GUESTMASK =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] && [[ $GUESTGW =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then

                GUESTNS=$(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv"|grep guestinfo.dns|awk -F'"' '{ print $4 }')
                GUESTDNS=$(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv"|grep guestinfo.domain|awk -F'"' '{ print $4 }')
                GUESTNAME=$(/usr/bin/vmtoolsd --cmd "info-get guestinfo.ovfEnv"|grep guestinfo.hostname|awk -F'"' '{ print $4 }')

                echo "auto lo" > /etc/network/interfaces
                echo "iface lo inet loopback" >> /etc/network/interfaces
                echo "allow-hotplug eth0" >> /etc/network/interfaces
                echo "iface eth0 inet static" >> /etc/network/interfaces
                echo " address $GUESTIP" >> /etc/network/interfaces
                echo " netmask $GUESTMASK" >> /etc/network/interfaces
                echo " gateway $GUESTGW" >> /etc/network/interfaces
				
				if [[ $GUESTNS =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
				
					echo " dns-nameservers $GUESTNS" >> /etc/network/interfaces
				
				fi
				
				if [[ -n $GUESTDNS ]]; then
					
					echo " dns-search $GUESTDNS" >> /etc/network/interfaces
				fi
				

                echo "127.0.0.1   localhost" > /etc/hosts
                echo "$GUESTIP   $GUESTNAME" >> /etc/hosts
                echo "$GUESTNAME" > /etc/hostname

                hostname $GUESTNAME

                /etc/init.d/networking stop
                /etc/init.d/networking start
                /etc/init.d/resolvconf stop
                /etc/init.d/resolvconf start

                ifdown eth0
                ifup eth0

        fi

fi

# https://kb.vmware.com/s/article/1014038
vmwtimesync=$(vmware-toolbox-cmd timesync status)
if [[ $vmwtimesync =~ "Disabled" ]]; then
        vmware-toolbox-cmd timesync enable
fi