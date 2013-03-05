
## Template Repositories 

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
