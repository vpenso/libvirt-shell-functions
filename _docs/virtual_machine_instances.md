# Virtual Machine Instances

It is possible to start as many virtual machines as your hardware supports. Basically it is limited by system memory. Before you start a virtual machine instance you need to select the host name to use. The command **network lookup** presents a list of names the DNS can resolve. Next you need to choose the virtual machine template to be used as the source. Get a list of all locally available templates with **template list**.  

There are two different modes of creating a virtual machine instance, cloning and shadowing. Using the command **clone** will create an independent copy of your virtual machine template, using potentially a lot of disk space. In contrast **shadow** will only create a virtual machine disk image to store differentials to the template disk image, thus saving local storage space. 

Both commands have identical command line syntax:

**vm clone|shadow TEMPLATE HOSTNAME**
 
## Virtual Machine Shadows

Virtual machine shadows to a virtual machine template can not be used standalone. You can check whether an instance is a shadow or a clone with the command **image info**, e.g.:

    $ vm cd lxdev01
    $ vm image info 
    image: /srv/vms/instances/lxdev01.devops.test/disk.img
    file format: qcow2
    virtual size: 40G (42949672960 bytes)
    disk size: 6.3M
    cluster_size: 65536
    backing file: /srv/vms/images/debian64-6.0.4-basic/disk.img (actual path: /srv/vms/images/debian64-6.0.4-basic/disk.img)

In case you want to keep an independent virtual machine instance for an easy backup, it is recommended to only use clones. 

## Virtual Machine Clones

Virtual machine instances cloned from a virtual machine template are completely decoupled (in contrast to a shadow). You can backup them simply by archiving their directory (make sure to shutdown the instance beforehand), e.g:

    $ vm cd lxdev01
    $ vm stop
    $ tar -czf lxdev01.devops.test.kvm.tgz *

Now you can copy this archive to a save location or to another computer to use it there.

## Virtual Machine Snapshots

**This feature is still in development!**

Freeze the state of a virtual machine instance using snapshot functionality. It is possible to snapshot a running virtual machine, but it takes quite a while. Create a snapshot like:

    $ vm cd lxdev01
    $ vm image snapshot create
    Domain snapshot 1325599831 created

Unfortunately it is not yet possible to label the snapshots. Display all available snapshots for a virtual machine instance with:

    $ vm image snapshot list
     Name                 Creation Time             State
    ---------------------------------------------------
     1325599831           2012-01-03 15:10:31 +0100 shutoff

Revert a virtual machine instance to a snapshot using its timestamp:

    $ vm image snapshot restore 1325599831

## Sharing Data with Instances

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
