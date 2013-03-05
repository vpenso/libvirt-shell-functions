

## Sharing Data with Instances


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
