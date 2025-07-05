Linux PCIe Driver
===========================
Supported Product Families (based on chipset): SDX65, SDX55

How to Build the driver
=======================
run "make" to generate the driver binaries: 
/host/mhi.ko 
/host/uci.ko 
/host/mhi_pci_semtech.ko 
/wwan/mhi_dtr.ko
/wwan/mhi_wwan_ctrl.ko
/wwan/mhi_wwan_mbim.ko
/qrtr/qrtr-mhi.ko

uci.ko 	   	 - QDSS/DPL Driver
mhi_dtr.ko 	 - RS232 signaling driver
mhi_wwan_mbim.ko - Network Interface Driver 
mhi_wwan_ctrl.ko - WWAN Control Interface Driver
qrtr/qrtr-mhi.ko - QRTR driver

How to Install the driver
========================= 
1. run "make install"
2. reboot

Note: Linux kernel may not load driver if secure boot is enabled in BIOS. 
Secure boot need to be disabled in BIOS and reboot.

How to verify driver installation
=================================
"lspci -v" should generate an output as below: 

04:00.0 Unassigned class [ff00]: Qualcomm Technologies, Inc Device 0306
	Subsystem: Device 18d7:0200
	Flags: bus master, fast devsel, latency 0, IRQ 188
	Memory at a1201000 (64-bit, non-prefetchable) [size=4K]
	Memory at a1200000 (64-bit, non-prefetchable) [size=4K]
	Capabilities: <access denied>
	Kernel driver in use: mhi-pci-semtech
	Kernel modules: mhi_pci_semtech

The WWAN Control Interface Driver exposes four device interfaces:
1. /dev/wwan0at0, AT port
2. /dev/wwan0mbim0, MBIM QMI interface
3. /dev/wwan0qmi0, QMI interface
4. /dev/wwan0qcdm0, QXDM interface

The QDSS/DPL Driver exposes two device interfaces:
1. /dev/mhi0_IP_HW_ADPL, DPL port
2. /dev/mhi0_QDSS, QDSS Port

How to communicate with AT port 
==================================
run "sudo minicom -D /dev/wwan0at0". 
To close it, press CTRL+A and then X

How to establish a data connection 
==================================
1. Turn on the radio
sudo mbimcli -d /dev/wwan0mbim0 -v -p --set-radio-state=on

2. Connect to the MB/cellular network
sudo mbim-network /dev/wwan0mbim0 start

3. Get IP addresses
sudo mbimcli -d /dev/wwan0mbim0 -v -p --query-ip-configuration

[/dev/mhichar0] IPv4 configuration available: 'address, gateway, dns, mtu'
     IP [0]: '25.168.250.74/30'
    Gateway: '25.168.250.73'
    DNS [0]: '64.71.255.254'
    DNS [1]: '64.71.255.253'
        MTU: '1460'

[/dev/mhichar0] IPv6 configuration available: 'address, gateway, dns, mtu'
     IP [0]: '2605:8d80:480:494d:687a:727d:2b6e:2bc3/64'
    Gateway: '2605:8d80:480:494d:9d20:80cb:80b8:b20e'
    DNS [0]: '2607:f798:18:10:0:640:7125:5254'
    DNS [1]: '2607:f798:18:10:0:640:7125:5253'
        MTU: '1460'

4. Set the IP addresses for the network interface
sudo ip addr add 25.168.250.74/30 dev wwan0
sudo ip addr add 2605:8d80:480:494d:687a:727d:2b6e:2bc3/64 dev wwan0

5. Set the MTU Size
sudo ifconfig wwan0 mtu 1460

6. Bring up the network interface and set the route 
sudo ip link set wwan0 up
sudo ip rout add default dev wwan0

7. Run "ifconfig" to check the status for wwan0
mhi_netdev0: flags=4291<UP,RUNNING>  mtu 1460
        inet 25.168.250.74  netmask 255.255.255.252  broadcast 0.0.0.0
        inet6 2605:8d80:480:494d:687a:727d:2b6e:2bc3  prefixlen 64  scopeid 0x0<global>
        RX packets 2  bytes 224 (224.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 44  bytes 9692 (9.6 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

8. DNS setting may have to be updated (one time only)
sudo vi /etc/systemd/resolved.conf

[Resolve]
#DNS=
FallbackDNS=8.8.8.8
#Domains=
#LLMNR=no
#MulticastDNS=no
#DNSSEC=no
#Cache=yes
#DNSStubListener=yes

Change FallbackDNS to have a value 8.8.8.8 as above. 

Restart systemd-resolved service
sudo systemctl restart systemd-resolved.service

The data connection should now be established.

How to disconnect a data connection 
==================================

1. Disonnect to the MB/cellular network
sudo mbim-network /dev/wwan0mbim0 stop

2. Bring down the network interface 
sudo ip link set wwan0 down

How to make multiple PDN connections
====================================

1. Add logical interface for individual PDP context.

sudo ip link add dev wwan0-1 parentdev wwan0 type wwan linkid 1

sudo ip link add dev wwan0-2 parentdev wwan0 type wwan linkid 2

Two logical interfaces (wwan0-1 and wwan0-2) were created. To verify, enter "ifconfig -a".

2. Turn on the radio. 

sudo mbimcli -d /dev/wwan0mbim0 -v -p --set-radio-state=on

3. Establish the data connection. 

sudo mbimcli -d /dev/wwan0mbim0 -v -p --connect=apn=sp.telus.com,ip-type=ipv4,session-id=1

After the connection is established, you can find the IP address, and MTU size. 
sudo mbimcli -d /dev/wwan0mbim0 -v -p --query-ip-configuration=1

4. Bring up the interface

sudo ip link set wwan0 up

sudo ip link set wwan0-1 up

sudo ifconfig wwan0-1 25.10.3.99/29 mtu 1460 up   (note: IP address and MTU size from 3)

5. Add the route for this IP address.

sudo route add -net 8.8.8.8 netmask 255.255.255.255 gw 25.10.3.100

6.  Establish another data connection.

sudo mbimcli -d /dev/wwan0mbim0 -v -p --connect=apn=isp.telus.com,ip-type=ipv4,session-id=2

7. Bring up the second interface

sudo ip link set wwan0-2 up
sudo ifconfig wwan0-2 10.142.184.188/29 mtu 1500 up (note: IP address and MTU size from 6)

8. Add the route for the second IP address.

sudo route add -net 4.2.2.2 netmask 255.255.255.255 gw 10.142.184.189

9. Run the ping test. 

ping 4.2.2.2 -c 1

ping 8.8.8.8 -c 1

You should see the responses for those ping requests.

10. Disconnect data call

sudo mbimcli -d /dev/wwan0mbim0 -v -p --disconnect=1
sudo mbimcli -d /dev/wwan0mbim0 -v -p --disconnect=2

11. Bring down the interface

sudo ip link set wwan0-1 down
sudo ip link set wwan0-2 down
sudo ip link set wwan0 down

12. Remove logical interfaces

sudo ip link del wwan0-1
sudo ip link del wwan0-2

How to resolve the mhi_pci_generic driver confliction
==================================
It is a known issue with new kernel (since 5.11) which has built-in mhi_pci_generic driver conflicting with our PCIe driver.

Before installing our driver.

04:00.0 Unassigned class [ff00]: Qualcomm Device 0306

    Subsystem: Device 18d7:0200

    Flags: fast devsel

    Memory at cc101000 (64-bit, non-prefetchable) [size=4K]

    Memory at cc100000 (64-bit, non-prefetchable) [size=4K]

    Capabilities: <access denied>

    Kernel modules: mhi_pci_generic

After installing our drivers

04:00.0 Unassigned class [ff00]: Qualcomm Device 0306

    Subsystem: Device 18d7:0200

    Flags: fast devsel

    Memory at cc101000 (64-bit, non-prefetchable) [size=4K]

    Memory at cc100000 (64-bit, non-prefetchable) [size=4K]

    Capabilities: <access denied>

    Kernel modules: mhi_pci_generic, mhi_pci_semtech

Our driver mhi_pci_semtech is installed but not in use.

To get it to work, need to add mhi_pci_generic in blacklist as below.

The following steps are applied to single Ubuntu installation. 

edit /etc/default/grub and update GRUB_CMDLINE_LINUX_DEFAULT variable with "modprobe.blacklist=mhi_pci_generic"

GRUB_CMDLINE_LINUX_DEFAULT="quiet splash modprobe.blacklist=mhi_pci_generic"

Then run "sudo update-grub2", and reboot.

Run "lspci -v" after reboot.

04:00.0 Unassigned class [ff00]: Qualcomm Device 0306

    Subsystem: Device 18d7:0200

    Flags: bus master, fast devsel, latency 0, IRQ 179

    Memory at cc101000 (64-bit, non-prefetchable) [size=4K]

    Memory at cc100000 (64-bit, non-prefetchable) [size=4K]

    Capabilities: <access denied>

    Kernel driver in use: mhi_pci_semtech

    Kernel modules: mhi_pci_generic, mhi_pci_semtech

You should see "Kernel driver in use: mhi_pci_semtech" which means our driver is being used.

For multiple Ubuntu installations,

boot up system with the first entry. 

sudo gedit /boot/grub/grub.cfg

identify the menuentry for the target OS and modify the line "linux /boot/vmlinuz-5.11.0-38-generic root=UUID=f4673308-d6b8-4312-a62f-2e6ff320473b ro  quiet splash $vt_handoff" for example.

Change this line to "linux  /boot/vmlinuz-5.11.0-38-generic root=UUID=f4673308-d6b8-4312-a62f-2e6ff320473b ro  quiet splash modprobe.blacklist=mhi_pci_generic $vt_handoff"

Power cycle the system and boot to target OS.


