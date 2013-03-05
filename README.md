Description
===========

Shell functions (Zsh/Bash) to manage clusters of local 
virtual machines on your workstation.

The following use-cases are supported:

* Setup of a [shared NATed network](_docs/nat_bridge.md) for all virtual 
machine instances. Enable external access to virtual machine instances
with [port forwarding](_docs/forward_port.md).
* Share virtual machine templates among coworkers.
* Manage the life cycle of multiple virtual machine instances.
* Data sharing between virtual machine instances and your workstation.
* Snapshot virtual machines and copy backup to remote storage.
* Provisioning of virtual machines with configuration management tool Chef.

We aim for very simple and lightweight code, and very transparent 
handling of external dependencies like:

* KVM 
* LibVirt
* SSH, Rsync, SSHfs 
* Chef 

Follow the [Installation Instructions](docs/installation.md) to
prepare your workstation for virtualization. Afterwards continue
reading [Getting Started](_docs/getting_started.md).

Copying
=======

Copyright 2011-2013 Victor Penso

Libvirt-Shell-Functions for working with virtual machines.

This is free software: you can redistribute it
and/or modify it under the terms of the GNU General Public
License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public
License along with this program. If not, see 
<http://www.gnu.org/licenses/>.
