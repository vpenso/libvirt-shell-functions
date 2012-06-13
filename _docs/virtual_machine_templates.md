# Virtual Machine Templates

One of the advantages of using virtual machines is the convenience of cloning them as many times as needed. It is recommended to maintain a set of basic virtual machine images call virtual machine templates in the following text. Whenever you want to provision a new virtual machine instance you inherit from a template.

## Create a New Template

Create a new virtual machine template using a ISO CD/DVD image containing the Linux distribution of your choice. Virtual machine templates are stored to the directory `/srv/vms/images/` by default (you can adjust this using the environment variable **$KVM_GOLDEN_IMAGES**). These templates should have meaningful names like:

* debian64-6.0.0-basic
* ubuntu64-10.04-desktop 
* debian64-6.0.4-chef-client-0.10.4 

### Basic installation

Start a virtual machine for the installation using an adjusted version of the _libvirt_ configuration file `_config/libvirt_install.xml`. 

    $ mkdir -p /srv/vms/images/debian64-6.0.5-basic
    $ cd /srv/vms/images/debian64-6.0.5-basic
    $ cp /srv/vms/_config/libvirt_install.xml .

Make sure to change the _domain/name_ the _devices/disk/source_ for the disk and the CDROM. Before you can install the operating system you need to prepare the disk image, which is in the case of Linux KVM created and initialized with the `kvm-img` command. (The parameter "40G" indicates the maximum size in GB the image can grow to, while being used.)

    $ kvm-img create -f qcow2 disk.img 40G
    $ virsh create libvirt_install.xml

Once the instance has started you need to connect a VNC client to the port 5901. While you follow the installation menu we propose to always create a minimal system configuration, which is the same across all golden images your create.

Set the following configuration options during installation:

* Keymap: English
* Host name is the distribution nick-name (e.g squeeze or lucid)
* Domain name 'devops.test'
* Single disk partition, no SWAP!
* Username is 'devops'
* Only standard system, no desktop environment (unless really needed), no services, no development environment,  no editor, nothing except a bootable Linux.

Once the installation is finished copy the _libvirt_ configuration file `_config/libvirt_instance.xml` and adjust _domain/name_ and _device/disk/source_, before starting the install virtual machine:

    $ cp /srv/vms/_config/libvirt_instance.xml .
    $ virsh create libvirt_instance.xml

Again you need to login using VNC port 5901. Install SSH, Sudo and Rsync:

    $ apt-get update
    $ apt-get install openssh-server sudo rsync
    $ apt-get clean

Elevate the _devops_ user to be able to run commands as root via Sudo:

    $ groupadd admin
    $ usermod -a -G admin devops

Append the following line to `/etc/sudoers`:

    %admin ALL=NOPASSWD: ALL

Remove the VNC related _device/graphics_ attribute from the `libvirt_instance.xml` configuration file, since login is provided by SSH now. When installation and final configuration is finished, shut down the instance and do not touch it anymore, but clone new virtual machines from there.

The virtual machine template directory should contain the following files at the end:

* The file containing the template image `disk.img`.
* The configuration `libvirt_instance.xml` used to start a virtual machine.
* The SSH configuration `ssh_config` for password-less login.
* The directory `keys/` holding the private/public key-pair used with SSH.

You may want to install the configuration management system Chef, to be included in the virtual machine template.

### Password-less Access

Enable SSH based password-less access by adding a SSH configuration **ssh_config** stored in the virtual machines directory, defining the login account name and the virtual machine IP-address:

    Host instance
      User devops
      HostName 10.1.1.11
      IdentityFile PATH_TO_VM_IMAGE/keys/id_rsa
      UserKnownHostsFile /dev/null
      StrictHostKeyChecking no

Another ingredient in this file is the 'IdentityFile', the public part of an SSH-key-pair stored in the sub-directory `keys/`. You can create a new password-less SSH key and uploaded it into the virtual machine using the following commands:

    $ mkdir keys
    $ ssh-keygen -q -t rsa -b 2048 -N '' -f keys/id_rsa
    $ vm exec 'mkdir -p -m 0700 $HOME/.ssh'
    $ vm put keys/id_rsa.pub .ssh/authorized_keys

### Template Compression

You can compress the disk image:

    $ kvm-img convert -c -f qcow2 -O qcow2 -o cluster_size=2M disk.img compressed.img
    $ mv compressed.img disk.img

# Template Repositories 

Once you have created a new image you can upload a copy to a remote repository. Define the remote location of the repository using the environment variable:

    export KVM_REMOTE_IMAGES=$USER@FQDN:PATH

Define a SSH connection string, as you would use with SCP. Check for the existence of the image you want to upload with **template list**, and push the archive to the remote server with:

    $ vm template list
     debian64-6.0.2.1-chef-client-0.10.4
     debian64-6.0.2-chef-client-0.10
     debian32-4.0.9-basic
     ubuntu64-11.04-desktop
    $ vm template remote upload debian32-4.0.9-basic

List all available images on the remote location with the **template remote list** command: 

    $ vm template remote list
    debian32-4.0.9-basic.kvm.tgz
    debian32-5.0.4-basic.kvm.tgz
    debian64-6.0.2.1-chef-client-0.10.4.kvm.tgz
    debian64-6.0.2-chef-client-0.10.kvm.tgz
    fedora32-15-basic.kvm.tgz
    scientificlinux-5.4-basic.kvm.tgz
    scientificlinux-6.0-basic.kvm.tgz
    ubuntu64-10.10-chef-client-0.10.2.kvm.tgz
    ubuntu64-11.04-desktop.kvm.tgz
    $ vm template remote download scientificlinux-6.0-basic.kvm.tgz


The same way you can download images to your local host.
