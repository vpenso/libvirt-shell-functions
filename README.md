Description
===========

Shell functions (Zsh/Bash) to manage local virtual machines.

The following use-cases are supported:

* Easy virtual machine networking setup.
* Easy use of shared virtual machine templates.
* Easy creation of virtual machine instances.
* Easy data sharing between virtual machine instances and your workstation.
* Snapshot virtual machines and backup to remote storage.
* Exchange of virtual machines between co-workers.
* Managing of complex virtual machine clusters running on your workstation.
* Provisioning of virtual machines with configuration management tools like Chef.

We aim for very simple and lightweight code, and very transparent handling of external dependencies like KVM, LibVirt, Qemu, SSH, Rsync, SSHfs and Chef. 

Find the installation instructions in `_docs/installation.md`

Usage
=====

    Usage: vm <command> [<sub-command>] [<args>]
    Shell-function to manage clusters of local virtual
    machines. (Version 0.6)

    Commands:
      network status|start|stop|lookup
        Manage the host-internal (NATed) network used
        to connect the virtual machine instance.
      status    
        Display the current state of instances.
      login [<hostname>]
        Opens a terminal to the defined instance or to
        the instance of the current working directory.
      cd <hostname>
        Change to the working directory of instance.
      template list
        Show local template images.
      template remote list|upload|download [<image>]
        Show remote template images. Upload or download
        at template from the remote storage by defining
        the template name.
      clone|shadow <template> <hostname> 
        Use a template for a new instance.
      forward <instance>:<port> <port>
        Enable port-forwarding. 

    Commands used in der instance working directory:
      start     
        Switch the instance on. 
      stop      
        Shutdown the instance down.
      kill      
        Kill the instance.
      remove    
        Shutdown and remove VM from system.
      exec <command>
        Run a command inside the instance.
      put <local_file> <instance_file>       
        Upload a file to the instance.
      get <instance_file> <local_file>       
        Download a file from the instance.
      sync <local_dir> <instance_dir>      
        Rsync a directory to the instance.
      fs mount|umount   
        Mount the VM root-directory.
      config solo|client [<server_hostname>]
        Provision the instance using Chef either in solo
        mode, or configure the client connection to an 
        Chef-server.
      config add cookbook|role [<cookbook>|<path_to_role>]
        Add a cookbook to the provison facility, by defing
        a cookbook name as target, or the path to a role
        file as target.
      image info|snapshot
        Manage/snapshot VM disk images.

    Overwrite environment variables:
      KVM_VM_INSTANCES
        Directory storing virtual machine instances.
      KVM_GOLDEN_IMAGES
        Directory holding virtual machine templates.
      KVM_REMOTE_IMAGES
        Where to download virtual machine templates.
      VIRSH_NET_CONFIG
        DNS/DHCP network configuration file.
      CHEF_COOKBOOKS
        Path to your Chef cookbooks.

Copying
=======

Copyright 2011 Victor Penso  
License [GPLv3][3] (see LICENSE file)

[3]: http://www.gnu.org/licenses/gpl-3.0.html
