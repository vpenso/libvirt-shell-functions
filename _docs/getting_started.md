Make sure you have read the [Installation Instructions][1] carefully before you continue reading this document.  

# Getting Started

The basic idea is to maintain a dedicated directory for each virtual machine and its configuration files (like the login credentials). Below you can see an example listing of such a virtual machine directory:

    $ ls $KVM_VM_INSTANCES/lxdev01.devops.test
    chef_attributes.json  
    chef_config.rb  
    cookbooks/
    disk.img  
    keys/  
    libvirt_instance.xml
    libvirt_install.xml
    roles/
    ssh_config

The **$KVM_VM_INSTANCES** environment variable defines the directory used to store all virtual machines directories (by default `/srv/vms/instances`). The directory name equals the host name (FQDN) of the virtual machine it contains. In the example above the directory is called `lxdev01.devops.test`. Note that in the default configuration virtual machines have the domain name **devops.test**.

## Download a Virtual Machine Template

This software makes it easy to share virtual machine templates among co-workers. (Create your own virtual machine template following these [instructions][2].) Simply define the location to download the template archives from using the shell environment variable **$KVM_REMOTE_IMAGES** (note that SCP is used to download files, in case you wonder about the syntax of the source path): 

    $ export KVM_REMOTE_IMAGES=$USER@hostname.domain:/path/to/the/templates

Echo the variable to check if it is set correctly. List virtual machine templates available at the remote location with:

    $ echo $KVM_REMOTE_IMAGES
    [... SNIP ...]
    $ vm template remote list
    debian32-4.0.9-server.kvm.tgz
    [... SNIP ...]
    debian64-6.0.4-basic.kvm.tgz
    debian64-6.0.4-chef-client-0.10.8.kvm.tgz
    ubuntu64-11.04-desktop.kvm.tgz

Now you can download on of the available templates:

    $ vm template remote download debian64-6.0.4-basic.kvm.tgz
    [... SNIP ...]

Virtual machine templates will be stored in`/srv/vms/images/` by default.

## Start a Virtual Machine Instance

When a virtual machine template is available on your computer you can clone it and start a virtual machine instance with the **clone** command. (Once you see that the instance is running it may need some time until it is booted and ready for login.) 

    $ vm clone debian64-6.0.4-basic lxdev01
    Booting........lxdev01.devops.gsi.de running
    $ vm login
    [... SNIP ...]

You can open a console session to the started virtual machine instance with **login** command. A listing of the status of all virtual machine instances known to the system can be displayed with **status** command:

    $ vm status
    lxdev01.devops.test running
    lxcm01.devops.test shut off

Use the commands **start** and **stop** to boot and shutdown a specific instance. _It is very important to remember that in order to manipulate a particular virtual machine instance you need to change into its container directory!_ For example to work with an instance called `lxcm01.devops.test` you would need to do:

    $ vm cd lxcm01
    $ vm start

Start and stop only power on and off a specific instance. The clone command deploys a virtual machine persistently. This means that stopped virtual machine instances are still registered in the system. In order to remove them permanently it necessary to use the command **remove**. 

Continue reading the [usage](_docs/usage.md). 

[1]: installation.md
[2]: templates.md
[3]: instances.md
