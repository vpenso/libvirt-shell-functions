## Interacting with a Virtual Machine Instance

### Login

Once you have started a virtual machine instance, change to its directory and login using the default user **devops**:

    $ vm cd lxdev01
    $ vm login
    Linux lxdev01 2.6.32-5-amd64 #1 SMP Tue Jun 14 09:42:28 UTC 2011 x86_64
    [... SNIP ...]
    Last login: Tue Oct 18 10:24:40 2011 from 10.1.1.1
    devops@lxdev01:~$ 

### Execute Commands

Note that the user "devops" is capable of running any command using sudo. In case you just want to execute a single command use the **exec** command:

    » vm exec uptime
     11:27:15 up 47 min,  1 user,  load average: 0.00, 0.01, 0.01
    » vm exec uname -a
    Linux lxdev01 3.2.0-4-amd64 #1 SMP Debian 3.2.35-2 x86_64 GNU/Linux

All parameters to the exec command will be executed as associated command lines using a login-shell inside the virtual machine. This means you can also execute interactive commands like:

    $ vm exec sudo passwd devops
    Enter new UNIX password: 
    Retype new UNIX password: 
    passwd: password updated successfully
    $ vm exec "sudo cat /etc/passwd" > passwd.backup
    $ vm exec "sudo cat /etc/passwd > passwd.backup"

There is a significant difference between the two commands above. In the first case you  execute the command in quotation marks inside the virtual machine and writing its output to a file stored in the local directory _outside_ of the virtual machine instance. The second command will write a file into the home-directory of the devops user _inside_ the virtual machine.

### Sudo Commands

Since `sudo` is used so frequently us can directly execute commands without necessity to prepend `exec`.

    » vm sudo ifconfig | grep HWaddr
    eth0      Link encap:Ethernet  HWaddr 02:ff:0a:0a:06:0b


