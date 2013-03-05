
## Port Forwarding

By default virtual machine instances are not accessible,
since they share closed network connected to the outside
LAN via a NAT. 

In order to allow access to a particular port of a virtual 
machine instance the command `vm forward` configures 
IPTables. The following example forwards the SSH port of
the virtual machine instance lxdev01 to the host port 2222:

    » vm forward
    vm forward <list|add|drop> [FQDN:PORT] [PORT]
    » vm forward add lxdev01:22 2222
    » vm forward list
    NAT rules:
    DNAT        tcp  --  0.0.0.0/0           0.0.0.0/0             tcp dpt:2222 to:10.1.1.11:22
    MASQUERADE  tcp  --  10.1.1.0/24         !10.1.1.0/24          masq ports: 1024-65535
    MASQUERADE  udp  --  10.1.1.0/24         !10.1.1.0/24          masq ports: 1024-65535
    MASQUERADE  all  --  10.1.1.0/24         !10.1.1.0/24         
    Forwarding:
    ACCEPT     tcp  --  0.0.0.0/0            10.1.1.11            tcp dpt:22
    ACCEPT     all  --  0.0.0.0/0            10.1.1.0/24          state RELATED,ESTABLISHED
    ACCEPT     all  --  10.1.1.0/24          0.0.0.0/0  
    » vm forward drop lxdev01:22 2222

Note that the forwarding will be still configured even if
the virtual machine is shutdown and removed. 
