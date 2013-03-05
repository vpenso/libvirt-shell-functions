
# Installation

Find the latest version of this software on <nop>GitHub:

https://github.com/vpenso/libvirt-shell-functions

Clone the repository and add the scripts to your shell environment:

    $ apt-get install git-core
    $ git clone git://github.com/vpenso/libvirt-shell-functions.git /srv/vms
    $ chmod 777 /srv/vms
    $ source /srv/vms/vm_functions.sh 

Prepare your computer to allow the execution of virtual machines 
following all steps described in the following section.

## Prerequisite

Make sure virtualization support is enabled in your firmware 
(BIOS/EFI), check with:

    $ egrep --color '(vmx|svm)' /proc/cpuinfo

Using a computer with enough memory is beneficial.It is  
recommend to use a 64Bit operating system since it can 
virtualize 32 and 64Bit virtual machines. For Debian/Ubuntu 
flavored system install the following packages:

    $ apt-get install kvm qemu libvirt-bin dnsmasq git-core chef xmlstarlet rsync sshfs

In case you are using a different Linux flavor, the package list 
above will help you to find the corresponding packages in another 
distribution.

**On Debian Squeeze:** Installing the _dnsmasq_ package in will 
start automatically an instance of the daemon. Before you continue 
make sure to shut it down and disable it from the boot process.

     $ sudo service dnsmasq stop
     $ sudo update-rc.d dnsmasq disable

Ubuntu is pre-configured to allow users to start virtual machines. 
In Debian follow these steps to enable your user account to manage 
virtual machines:

    $ sudo adduser `id -un` libvirt
    $ sudo adduser `id -un` kvm

Make sure to add your account name to `/etc/libvirt/qemu.conf`,

    user = "USER"

where `USER` is the name of the user that should be able to start 
VMs talking to the system qemu/libvirt bus.

*Re-login* to activate these group rights. Add the following to 
your shell environment to make sure to communicate only to the 
system-wide instance of _libvirtd_.

    $ export LIBVIRT_DEFAULT_URI=qemu:///system 
    $ export VIRSH_DEFAULT_CONNECT_URI=qemu:///system

## Networking

All virtual machine instances run inside a host-internal network 
shared by all virtual machines, connected to the external world using 
a NAT. Enable the network bridge with:


    $ vm network start
    Network 'nat_bridge' started
    $ vm network status
    Name            nat_bridge
    UUID            f68a4de1-ce37-c59a-aeac-fcd189a07fd7
    Active:         yes
    Persistent:     yes
    Autostart:      yes
    Bridge:         nbr0


