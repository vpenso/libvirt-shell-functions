
Start the network hosting virtual machine instances following the [Installation Instrucations][1]. 

# Virtual Machine Network

The environment variable **$VIRSH_NET_CONFIG** points to the default network configuration. Fortunately _libvirt_ makes it very easy setup a NATted network bridge. Take a look at the corresponding configuration file in `_config/libvirt_nat_bridge.xml`.

The network-description in this file tells libvirt to create a network bridge called **nbr0**. (This involves the configuration of [[http://www.netfilter.org/][iptables]] to act as NAT and to route IP-traffic. Furthermore it starts a [[http://www.thekelleys.org.uk/dnsmasq/doc.html][dnsmasq]] process serving DHCP and DNS resolution for the virtual machines.)

The network bridge can be enabled and disabled with the commands **network start|stop**. Enabling means to deploy the configuration boot-persistent. **network status** displays the current setup.  List all known hostnames with their associated IP-addresses with **network lookup**: 

    $ vm network lookup
    lxdns01.devops.test -- 10.1.1.2
    lxcm01.devops.test -- 10.1.1.3
    lxrm01.devops.test -- 10.1.1.4
    lxb001.devops.test -- 10.1.1.5
    lxb002.devops.test -- 10.1.1.6
    lxb003.devops.test -- 10.1.1.7
    lxb004.devops.test -- 10.1.1.8
    lxmon01.devops.test -- 10.1.1.9
    lxfs01.devops.test -- 10.1.1.10
    lxdev01.devops.test -- 10.1.1.11
    lxdev02.devops.test -- 10.1.1.12
    lxdev03.devops.test -- 10.1.1.13

## Port Forwarding

**This feature is still under development!**

Open a network port from a virtual machine instance inside the host-internal network to the world with the command:

**vm forward HOSTNAME:PORT PORT**
 
[1]: installation.md
