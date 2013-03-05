
## Shared Network with NAT 

The environment variable **$VIRSH_NET_CONFIG** points to the default network configuration. Fortunately _libvirt_ makes it very easy setup a NATted network bridge. Take a look at the corresponding configuration file [_config/libvirt_nat_bridge.xml](../_config/libvrit_nat_bridge.xml).

The network-description in this file tells libvirt to create a network bridge called **nbr0**. (This involves the configuration of [iptables](http://www.netfilter.org/) to act as NAT and to route IP-traffic. Furthermore it starts a [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html) process serving DHCP and DNS resolution for the virtual machines.)

The network bridge can be enabled and disabled with the commands **network start|stop**. Enabling means to deploy the configuration boot-persistent. **network status** displays the current setup.  List all known host names with their associated IP-addresses with **network lookup**.

    » vm network status
    Name            nat_bridge
    UUID            0c3cf3f3-f6bc-ffdb-7ecc-32e89d2f59ff
    Active:         yes
    Persistent:     yes
    Autostart:      yes
    Bridge:         nbr0
    » vm network lookup
    10.1.1.2 lxdns01.devops.test
    10.1.1.3 lxcm01.devops.test
    10.1.1.4 lxrm01.devops.test
    10.1.1.5 lxb001.devops.test
    10.1.1.6 lxb002.devops.test
    10.1.1.7 lxb003.devops.test
    [...SNIP...]

On Ubuntu (>12.04) you can query the `dnsmasq` instance started from libvirt by adding its IP to the NetworkManager configuration. Write `nameserver 10.1.1.1` into the file `/etc/resolvconf/resolv.conf.d/head`. After restarting the service with `sudo restart network-manager` you should be able to lookup hosts from the devops.test domain.
 
