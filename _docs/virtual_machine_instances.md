# Virtual Machine Instances

Once you have started a virtual machine instance, change to its directory and login using the default user **devops**:

    $ vm cd lxdev01
    $ vm login
    Linux lxdev01 2.6.32-5-amd64 #1 SMP Tue Jun 14 09:42:28 UTC 2011 x86_64
    [... SNIP ...]
    Last login: Tue Oct 18 10:24:40 2011 from 10.1.1.1
    devops@lxdev01:~$ 

Note that the user "devops" is capable of running any command using sudo. In case you just want to execute a single command use the **exec** command:

    $ vm exec sudo ifconfig | grep HWaddr
    eth0      Link encap:Ethernet  HWaddr 02:ff:0a:0a:06:0b  

All parameters to the exec command will be executed as associated command lines using a login-shell inside the virtual machine. This means you can also execute interactive commands like:

    $ vm exec sudo passwd devops
    Enter new UNIX password: 
    Retype new UNIX password: 
    passwd: password updated successfully
    $ vm exec "sudo cat /etc/passwd" > passwd.backup
    $ vm exec "sudo cat /etc/passwd > passwd.backup"

There is a significant difference between the two commands above. In the first case you  execute the command in quotation marks inside the virtual machine and writing its output to a file stored in the local directory _outside_ of the virtual machine instance. The second command will write a file into the home-directory of the devops user _inside_ the virtual machine.

Moving single files in and out of the virtual machine is possible using the **get** and **put** commands. Entire directory structures can be pushed using **sync** (which uses Rsync behind the scenes). The following example shows how to deploy your own shell configuration to the virtual machine instance:

    $ vm exec sudo apt-get install zsh
    [... SNIP ...]
    $ vm exec sudo usermod -s /bin/zsh devops
    $ vm put ~/.zshrc /home/devops
    $ vm sync ~/.zsh /home/devops/
    $ vm login

The sync command is one-directional and will only push local files into virtual machine instance, but not into the reverse direction.

Last you can decide to mount the virtual machine file system with **fs mount**:

    $ vm fs mount
    $ cat mnt/etc/hostname
    lxdev01
    $ vm fs umount

In this case you have full read and write access to the entire virtual machine!
