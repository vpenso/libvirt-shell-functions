# Virtual Machine Templates

One of the advantages of using virtual machines is the convenience of cloning them as many times as needed. It is recommended to maintain a set of basic virtual machine images also call templates or golden images. Whenever you want to provision a new deployment you start from one such virtual machine template.

## Create a New Template

To install a new virtual machine you will need an ISO CD/DVD image containing the Linux distribution of your choice. Virtual machine templates get stored to a directory defined using the environment variable **$KVM_GOLDEN_IMAGES**, which is by default `/srv/vms/images/`.

These images should be never instantiated once they are installed. The folders holding particular virtual machine templates are named according to the distribution name, version, and bitness. Examples are:

   * debian64-6.0.0-basic
   * ubuntu64-10.04-desktop 
   * debian64-6.0.2.1-chef-client-0.10.4 

Edit the template file `_configl/ibvirt_install.xml` accordingly, in order to begin the installation of the new Golden Image. You should adjust the tag source file from both, the disk and CDROM devices, so they would point to the right paths.

Before you can install the operating system you need to prepare a virtual machine disk image, which is in the case of Linux KVM created and initialized with the `kvm-img` command. (The parameter "40G" indicates the maximum size in GB the image can grow to, while being used.)

    $ kvm-img create -f qcow2 disk.img 40G
    $ virsh create libvirt_install.xml

Once the instance has started you need to connect a VNC client to the port 5905. While you follow the installation menu we propose to always create a minimal system configuration, which is the same across all golden images your create.

We set the following configuration options during installation:

   * Keymap: English
   * Host name is the distribution nick-name (e.g squeeze or lucid)
   * Domain name 'devops.test'
   * On big disk partition, no SWAP!
   * Username is 'devops'
   * Only standard system, no desktop environment (unless really needed), no services, no development environment,  no editor, nothing except a bootable Linux.

After the installation is finished, we elevate the devops user to be able to run commands as root via Sudo:

    $ apt-get update
    $ apt-get install openssh-server sudo rsync
    $ apt-get clean
    $ groupadd admin
    $ usermod -a -G admin devops

We add the following line to `/etc/sudoers`:

    %admin ALL=NOPASSWD: ALL

When installation and final configuration is finished, shut down the instance and do not touch it anymore, but clone new virtual machines from there.

You can compress the disk image:

    $ kvm-img convert -c -f qcow2 -O qcow2 -o cluster_size=2M disk.img compressed.img
    $ mv compressed.img disk.img

As a last step we add a libvirt configuration used to start a virtual machine instance of this template. Adjust `_config/libvirt_instance.xml` accordingly.

The Golden Image directory should contain the following files at the end:

   * The file containing the golden image **disk.img**.
   * The configuration `libvirt_install.xml` used to install the operating system, for later reference.
   * The configuration `libvirt_instance.xml` used to start a virtual machine. This file needs to be adjusted after the golden image was cloned.

## Password-less Access

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
