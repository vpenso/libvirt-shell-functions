
Start the network hosting virtual machine instances following the [Installation Instrucations][1]. 

# Virtual Machine Network

The environment variable **$VIRSH_NET_CONFIG** points to the default network configuration. Fortunately _libvirt_ makes it very easy setup a NATted network bridge. Take a look at the corresponding configuration file in `_config/libvirt_nat_bridge.xml`.

The network-description in this file tells libvirt to create a network bridge called **nbr0**. (This involves the configuration of [iptables](http://www.netfilter.org/) to act as NAT and to route IP-traffic. Furthermore it starts a [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html) process serving DHCP and DNS resolution for the virtual machines.)

The network bridge can be enabled and disabled with the commands **network start|stop**. Enabling means to deploy the configuration boot-persistent. **network status** displays the current setup.  List all known hostnames with their associated IP-addresses with **network lookup**.

On Ubuntu (>12.04) you can query the `dnsmasq` instance started from libvirt by adding its IP to the NetworkManager configuration. Write `nameserver 10.1.1.1` into the file `/etc/resolvconf/resolv.conf.d/head`. After restarting the service with `sudo restart network-manager` you should be able to lookup hosts from the devops.test domain.

## Port Forwarding

**This feature is still under development!**

Open a network port from a virtual machine instance inside the host-internal network to the world with the command:

**vm forward HOSTNAME:PORT PORT**
 
[1]: installation.md
