# next version

* Add contributors list.
* Solve compatibility issue with `virsh list`
* Rename function `vmid` to `__vm_id`
* `vm start|stop` prints better user output now
* Adding a couple of preconfigured DNS names `lxfs0[1-6]`
* Improvements in the installation documentation.
* [BUG] Don't overwrite `$KVM_REMOTE_IMAGES`.
* Display a message to indicate `$KVM_REMOTE_IMAGES` isn't set.

# 1.3

* `vm network lookup` pints in `/etc/hosts/` friendly format
* `vm config add` creats directories silently
* [BUG] `vm remove` should undefine VM even if it is shutdown already
* Adding DNS config to `_config/libvirt_nat_bridge.xml`
* Adding a command `vm sudo`.
* [BUG] `_config/libvirt_install.xml` screwup with attribute quotation marks
* [BUG] `_config/libvirt_instance.xml` missing '/' in tag 

# 1.2

* `vm config add role` print more verbose output for
  users.
* Using virtio for the libvirt templates as default.
* `vm forward` can list and drop iptables rules now.
* [BUG] `chef_attributes.json` and `chef_config.rb` 
  should be generated with proper line-feeds in Bash.

# 1.1

* Support for multiple Chef cookbook source directories
  when using the `vm config add cookbook` command.
* Adding support for Chef data-bags used together with 
  _chef-solo_.
* Chef if `KVM_REMOTE_IMAGE` is set before running 
  `vm template remote` commands.
* [BUG] Support different handling of here-doc in Zsh/Bash. 
* [BUG] Make sure to always alert users to add cookbooks,
  before running, `vm config solo`

# 1.0

First official version released on GitHub.
