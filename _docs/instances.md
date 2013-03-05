
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

