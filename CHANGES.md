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
