#---------------------------------------------------------------
#
# Shell functions for working with virtual machines.
#
# This is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be 
# useful, but WITHOUT ANY WARRANTY; without even the implied 
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
# PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public 
# License along with this program. If not, see 
#
#   <http://www.gnu.org/licenses/>.
#
#----------------------------------------------------------------
# Author: Victor Penso
# Copyright 2011
_version=1.0
#----------------------------------------------------------------


# enable line numbers for debug output
if [ "$_DEBUG" = "true" ]
then
  # no double quotes here!
  export PS4='(${BASH_SOURCE}:${LINENO}):${FUNCNAME[0]}-[${SHLVL},${BASH_SUBSHELL},$?] '
fi
# print log output only in debugging mode
function _log() {
  if [ "$_DEBUG" = "true" ]; then
    echo 1>&2 "debug: $@"
  fi
}
# alert the user about a problem
function _error() { 
  echo 1>&2 "error: $@" 
}

# ----------------------------------------------------------------------
##
## Default for environments variables
##

# Users can overwrite these variables to adjust the functions
# to their environment!

# Where the virtual machines get stored
KVM_VM_INSTANCES=${KVM_VM_INSTANCES:-"/srv/vms/instances"}
# Golden images used to clone virtual machines from
KVM_GOLDEN_IMAGES=${KVM_IMAGES:-"/srv/vms/images"}
# Remote location for golden images
KVM_REMOTE_IMAGES=''
# Network configuration to libvirt
VIRSH_NET_CONFIG=${VIRSH_NET_CONFIG:-"/srv/vms/_config/libvirt_nat_bridge.xml"}
# Network domain
VIRSH_NET_CONFIG_DOMAIN=".devops.test"

if [ ! -d $KVM_GOLDEN_IMAGES ] 
then
  mkdir $KVM_GOLDEN_IMAGES
  _log "Create image directory: $KVM_GOLDEN_IMAGES" 
fi

if [ ! -d $KVM_VM_INSTANCES ]
then
  mkdir --mode 777 $KVM_VM_INSTANCES
  _log "Create instance directory: $KVM_VM_INSTANCES"
fi

# ----------------------------------------------------------------------
##
## Prepare the host-internal network
##

# appends the domain name if it is missing
function __vm_fqdn() {
  local _instance=$1
  # if no parameter is appended return nothing
  if [ ! -z $_instance ]; then
    # check if the domain name is part of the instance name 
    if ! `echo $_instance | grep -q "$VIRSH_NET_CONFIG_DOMAIN"`; then
      # append the domain name if missing
      echo $_instance$VIRSH_NET_CONFIG_DOMAIN
      _log "[__vm_fqdn] Appending domain name to '$_instance'."
    else
      echo $_instance
    fi
  fi
}

function __vm_ip() {
  local _help=\
"Prints the IP-address of a virtual machine instance,
by reading the network configuration in:

  \$VIRSH_NET_CONFIG

Returns the IP-address associated with a given hostname,
unless no parameter is applied. Then the IP-address of 
the virtual machine in the current working directory is 
returned if possible. In case no IP-address can be found 
the function returns nothing."
  if [ "$1" = "help" ]; then
    echo $_help
  else
    local _instance=
    if $(__vm_container_directory); then
      _instance=$(__vm_name) 
    else 
      _instance=$(__vm_fqdn $1)
    fi
    if [ ! -z $_instance ]; then
      _log "[__vm_ip] Looking for IP-address of '$_instance'."
      xmlstarlet sel -t -m "//network/ip/dhcp" \
       -v "host[@name='$_instance']/@ip" $VIRSH_NET_CONFIG
    fi
  fi
}

function __vm_mac() {
  local _help=\
"Prints the MAC-address of a virtual machine instance,
by reading the network configuration in:

  \$VIRSH_NET_CONFIG

Returns the MAC-address associated with a given hostname,
unless no parameter is applied. Then the MAC-address of
the virtual machine in the current working directory is
returned if possible. In case no MAC-address can be found
the function returns nothing."
  if [ "$1" = "help" ]; then
    echo $_help
  else
    local instance=
    if $(__vm_container_directory); then
      _instance=$(__vm_name) 
    else
     _instance=$(__vm_fqdn $1)
    fi
    if [ ! -z $_instance ]; then
      _log "[__vm_mac] Locking for MAC-address of '$_instance'."
      xmlstarlet sel -t -m "//network/ip/dhcp" \
        -v "host[@name='$_instance']/@mac" $VIRSH_NET_CONFIG
    fi
  fi
}

function __vm_network() {
  local _help=\
"Manage the host-internal (NATed) network used by all
virtual machine instance. 

  vm network status|start|stop|lookup

The command 'lookup' list all FQDNs and their IPs known
to the internal DNS server."
  local _command=$1
  local _bn='nat_bridge'
  case "$_command" in
  status) virsh net-info $_bn ;;
  start) 
    # define a persistent host-internal network
    virsh net-define $VIRSH_NET_CONFIG > /dev/null 2>&1
    _log "[__vm_network] Defining network from '$VIRSH_NET_CONFIG'."
    virsh net-start $_bn > /dev/null 2>&1
    _log "[__vm_network] Starting network '$_bn'."
    # make it boot-persistent, also
    virsh net-autostart $_bn > /dev/null 2>&1
    _log "[__vm_network] Making network '$_bn' boot persistent."
    echo "Network '$_bn' started"
    ;;
  stop)
    virsh net-destroy $_bn > /dev/null 2>&1
    _log "[__vm_network] Shutdown network '$_bn'."
    virsh net-undefine $_bn > /dev/null 2>&1
    _log "[__vm_network] Un-defining network '$_bn'."
    echo "Network '$_bn' stopped"
    ;; 
  lookup)
    xmlstarlet sel -t -m "//network/ip/dhcp/host" \
      -v "@name" -o " -- " -v "@ip" -n $VIRSH_NET_CONFIG
    ;;
  *) echo $_help ;;
  esac
}

# ----------------------------------------------------------------------
##
## Access the virtual machine meta data
##

function __vm_name() { 
  if [[ -e $PWD/libvirt_instance.xml ]]; then
    xmlstarlet sel -t -v "/domain/name" $PWD/libvirt_instance.xml 
  fi
}

function vmid() { 
  virsh list --all | awk '{gsub(/^ +| +$/,"")}1' | grep $(__vm_name) | cut -d' ' -f2 
}




# ----------------------------------------------------------------------
##
## Accessing a virtual machine instance
##

function __vm_ssh() { 
  if [ ! $# -eq 0 ]
  then
    _log "[__vm_ssh] Executing command '$@'."
  fi
  ssh -qt -F $PWD/ssh_config instance $@; 
}

function __vm_login() {
  local _instance=$1
  # if the user explicitly defines a virtual machine 
  # instance to login
  if [ ! -z $_instance ]; then
    # make sure to use the FQDN of the defined instance
    _instance=$(__vm_fqdn $_instance)
    _log "[__vm_login] Changing to work-directory of $_instance"
    # change to the container directory of the instance
    cd $KVM_VM_INSTANCES/$_instance
  fi
  # otherwise it is assumed that $PWD is an instance 
  # container directory
  __vm_ssh
}


function __vm_put() { 
  local _help=\
"Usage: vm put <local_path> <instance_path>

Upload a file into a running virtual machine instance.
First parameter is the path to a local file, and the
second is the path inside the virtual machine file-system."
  # do we have exactly two arguments?
  if [ $# -ne 2 ]; then
    _error "Not enough arguments!"
    echo $_help
  else
    # copy the file
    local _source=$1
    local _destination=$2
    _log "[__vm_put] Uploading file '$_source' to '$(__vm_name):$_destination'."
    scp -q -F $PWD/ssh_config $_source instance:$_destination
  fi
}

function __vm_get() { 
  local _help=\
"Usage: vm get <instance_path> <local_path>
  
Download a file from the virtual machine instance.
First parameter is the path inside the virtual 
machine file-system, second the path to the local
file." 
  if [ $# -ne 2 ]; then
    _error "Broken arguments!"
    echo $_help
  else
    local _source=$1
    local _destination=$2
    _log "[__vm_get] Downloading file '$(__vm_name):$_source' to '$_destination'."
    scp -q -F $PWD/ssh_config instance:$_source $_destination
  fi
}

function __vm_sync() {
  local _help=\
"Usage: vm sync <local_dir> <instance_dir>

Recursive upload a directory to the virtual machine
instance. First parameter is the path to the local
directory, and second parameter is the path in the
virtual machine instance file-system. After the first 
upload a differential sync is done."
  if [ $# -ne 2 ]; then
    _error "Broken arguments!"
    echo $_help
  else
    local _source=$1
    local _destination=$2
    _log "[__vm_sync] Syncing '$_source' to '$(__vm_name):$_destination'."
    rsync --exclude '.git' --exclude '.gitignore'\
      --recursive --copy-links --copy-dirlinks --verbose \
      -e "ssh -q -F $PWD/ssh_config" $_source instance:$_destination
  fi
}

# us SSHFS to mount the virtual machine instance root-directory
function __vm_fs() {
  local _help=\
"Usage: vm fs mount|umount
  
Mount/unmount the virtual machine instance file-system.
The mount-point 'mnt/' will be connected with root
privileges."
  # check for the name of the SFTP-service
  local _command=$1
  local _sftp_path=$(vm exec "sudo grep Subsystem /etc/ssh/sshd_config | cut -d ' ' -f 3 | tr -d '\n'" )  
  # make sure to have a mount-point
  mkdir $PWD/mnt
  case "$_command" in
  mount)
    _log "Mounting virtual machine file-system."
    sshfs -F $PWD/ssh_config -o sftp_server="/usr/bin/sudo $_sftp_path" instance:/ $PWD/mnt/ 
    ;;
  umount)
    _log "Unmounting virtual machine file-system."
    fusermount -u $PWD/mnt/ 
    ;;
  *)
    _error "The command '$_command' is not supported!"
    echo $_help 
    ;;
  esac
}

# ----------------------------------------------------------------------
##
## Managing the virsh configuration
##

# Adjust the virtual machine configuration files:
# 
#  * libvirtd_instance.xml
#  * ssh_config
#
# to the current directory.
function __vm_reloc() {
  # change the SSH client configuration file
  input="  IdentityFile $PWD/keys/id_rsa";
  sed "s|^  Iden.*|$input|g" ssh_config > /tmp/dump.txt;
  mv /tmp/dump.txt ssh_config;
  _log "[__vm_reloc] Configuring SSH key location in '$PWD/ssh_config'"
  # change the libvirt configuration file
  local _hostname=${PWD##*/}
  xmlstarlet ed \
   -u "/domain/name" -v $_hostname \
   -u "/domain/devices/disk/source[@file]/@file" -v "$PWD/disk.img" \
   libvirt_instance.xml > /tmp/dump.txt;
  mv /tmp/dump.txt libvirt_instance.xml;
  _log "[__vm_reloc] Configuring '$PWD/libvirt_instance.xml'"
}

# Change the virtual machine MAC- and IP-address, e.g.:
#
#   __vm_network_config 02:FF:0A:0A:06:04 10.1.1.4
#
function __vm_network_config() {
  local _dump=/tmp/dump.xml
  # change the IP-address in the SSH configuration
  _log "[__vm_network_config] Configuring IP-address in '$PWD/ssh_config'."
  input="  HostName $2"
  sed "s|^  HostNam.*|$input|g" ssh_config > $_dump;
  mv $_dump ssh_config;
  # change mac-address in the libvirt configuration file
  _log "[__vm_network_config] Configuring MAC-address in '$PWD/libvirt_instance.xml'"
  xmlstarlet ed \
    -u "/domain/devices/interface/mac[@address]/@address" -v "$1" \
    libvirt_instance.xml > $_dump;
  mv $_dump libvirt_instance.xml;
}

function __vm_hostname() {
  local _fqdn=$1
  local _name=`echo $_fqdn | cut -d. -f1`
  local _ip=$2
  __vm_ssh "sudo sh -c 'echo $_name > /etc/hostname' " > /dev/null 2>&1
  __vm_ssh "sed '2 c $_ip $_fqdn $_name' /etc/hosts > /tmp/dump.txt" > /dev/null 2>&1 
  __vm_ssh "sudo sh -c 'mv /tmp/dump.txt /etc/hosts'" > /dev/null 2>&1 
  __vm_ssh "sudo sh -c '/etc/init.d/hostname.sh'" > /dev/null 2>&1 
  _log "[__vm_hostname] Configuring instance name $_name using SSH login."
}

# --------------------------------------------------------------
##
## Access the network configuration for a particular
## virtual machine.
##


# Port-forwarding of a host port to a virtual machine instance
# port.
#
#  vmmap lxdev01.devops.test:22 2201
#
function vmportforward() {
  local _name=`echo $1 | cut -d: -f1`
  local _ip=$(__vm_ip $_name)
  local _port=`echo $1 | cut -d: -f2`
  sudo iptables -A PREROUTING -t nat -i eth0 -p tcp --dport $2 -j DNAT --to $_ip:$_port
  sudo iptables -I FORWARD 1 -p tcp -d $_ip --dport $_port -j ACCEPT
}

# -----------------------------------------------------------
##
## Virtual machine image management
##

function __vm_image() {
  local _command=$1
  local _sub_command=$2
  local _help=\
"Usage: vm image <command> [<subcommand>] [<args>]

Available commands are:
  info
    Show the properties of the disk image.
  snapshot <subcommand> [<args>]
    Manage snapshots of the disk image."
  case "$_command" in
  info) kvm-img info $PWD/disk.img ;;
  snapshot)
    case "$_sub_command" in
    list) virsh snapshot-list $(vmid) ;;
    create) virsh snapshot-create $(vmid) ;;
    restore) virsh snapshot-revert $(vmid) $3 ;;
    delete) virsh snapshot-delete $(vmid) $3 ;;
    *) _error "list|create|restore|delete are available commands!" ;;
    esac
    ;;
  *) 
    _error "The command '$_command' is not supported!" 
    echo $_help
    ;;
  esac
}


function vmtemplate() {
  local _suffix=".kvm.tgz"
  case "$1" in
    list) 
      find $KVM_GOLDEN_IMAGES -maxdepth 1 -mindepth 1 -type d -printf "%P\n" | sort
      ;;
    remote)
      case "$2" in
        list)
          local _name=`echo $KVM_REMOTE_IMAGES | cut -d: -f1`
          local _path=`echo $KVM_REMOTE_IMAGES | cut -d: -f2`
          ssh $_name "find $_path -name '*$_suffix' -printf '%P\n' | sort"
          ;;
        upload)
          cd $KVM_GOLDEN_IMAGES
          tar -czf $3$_suffix $3
          scp $3$_suffix $KVM_REMOTE_IMAGES
          cd -
          ;;
        download)
          local _ans=
          cd $KVM_GOLDEN_IMAGES
          if [[ -f $3 ]]; then
            echo -n "Overwrite? (y/n): "
            read _ans
          else
            _ans="y"
          fi
          if [[ "$_ans" == "y" ]]; then
            scp $KVM_REMOTE_IMAGES/$3 .
            echo -n "Decompressing image..."
            tar -xzf $3
            echo "done"
          fi
          cd -
          ;;
        *)
          echo "Error: list|upload|download are available parameters!"
          echo "Remote KVM virtual machine images are stored in:"
          echo "  KVM_REMOTE_IMAGES=$KVM_REMOTE_IMAGES"
          ;;
      esac
      ;;
    *)
      echo "Error: list|remote are available parameters!"
      ;;
  esac
}

#-------------------------------------------------------------
##
## Virtual Machine Instance Management
##

function __vm_instance_running() {
  local _instance=$1
  virsh list | grep $_instance > /dev/null 2>&1
}

# Return true if the current working directory is
# virtual machine container.
function __vm_container_directory() { 
  test ! -z $(__vm_name) 
}

function __vm_instance_start() {
  local _config=$PWD/libvirt_instance.xml
  local _instance=$(__vm_name)
  _log "[__vm_instance_start] Defining virtual machine from '$_config'."
  virsh define $_config > /dev/null 2>&1
  _log "[__vm_instance_start] Stating instance '$_instance'."
  virsh start $_instance > /dev/null # display error messages
  if [ $? -eq 0 ]
  then echo "Instance $_instance started"
  fi
}

# kills the instance without graceful shutdown and
# removes it from the libvirt configuration
function __vm_instance_remove {
  local _instance=$(__vm_name)
  if $(__vm_instance_running $_instance) ; then
    _log "[__vm_instance_remove] Killing instance '$_instance'."
    virsh destroy $_instance > /dev/null 2>&1
    sleep 1 # wait for the instance to be killed
    _log "[__vm_instance_remove] Un-define instance: '$_instance'."
    virsh undefine $_instance > /dev/null 2>&1
    echo "Instance $_instance removed"
  fi
}

function __vm_clone() {
  # Print a help message if parameters are missing
  local _help=\
"Usage: vm clone|shadow <template> <hostname>
 
Creates a virtual machine instance using a template.
Clone will make a copy of the disk image, where as 
shadow only stores a differential image file. First
parameter is the template to use, and the second the
hostname to be applied."
  if [ $# -ne 2 ]; then
    echo $_help
  # Otherwise clone the instance
  else
    # make sure to outside a virtual machine container
    cd $HOME 
    # virtual machine image to use for cloning
    local _template=$KVM_GOLDEN_IMAGES/$1
    # make sure to have the FQDN of the instance
    local _instance=$(__vm_fqdn $2)
    # target instance container directory
    local _target=$KVM_VM_INSTANCES/$_instance
    # ask the user to remove an existing instance
    if [ -d $_target ]; then
      echo -n "Remove existing instance '$_instance' (y/n)?: "
      read ans
      if [ "$ans" = "y" ]; then
        cd $_target
        __vm_instance_remove 
        cd - > /dev/null
        _log "[__vm_clone] Deleting instance container directory: $_target"
        rm -rf $_target
      fi
    fi
    # don't overwrite
    if [ ! -d $_target ]; then
      _log "[__vm_clone] Template used for instance: $_template"
      if [ "$_clone_shadow" = "true" ]; then
        mkdir $_target
        qemu-img create -b $_template/disk.img -f qcow2 $_target/disk.img > /dev/null
        cp -R -n $_template/* $_target 
        _log "[__vm_clone] Deploying template shadow to '$_target'."
      else
        # clone the virtual machine template
        cp -R $_template $_target
        _log "[__vm_clone] Deploying template clone to '$_target'."
      fi
      # prepare the configuration files
      local _ip=$(__vm_ip $_instance)
      local _mac=$(__vm_mac $_instance)
      _log "[__vm_clone] Instance network $_instance at $_ip ($_mac)."
      cd $_target
      __vm_reloc
      __vm_network_config $_mac $_ip
      __vm_instance_start
      echo -n 'Booting.'
      while :; do # try to connect
        ping -c 1 $_ip >/dev/null 2>&1 
        # set the hostname
        if [ $? = 0 ]
        then # if network interface up
          break
        fi
        sleep 1
        echo -n '.'
      done
      echo "done"
      _log "[__vm_clone] Waiting for SSH service to come up."
      # wait for the SSH service to come up
      netcat $_ip 22 -w 30 -q 0 < /dev/null > /dev/null 2>&1
      __vm_hostname $_instance $_ip
    else
      _error"'$_target' exists!"
    fi
  fi
}

# ------------------------------------------------------------------
##
## Using the Chef configuration management with virtual machines
##

# Path to the users Chef cookbooks
CHEF_COOKBOOKS=${CHEF_COOKBOOKS:-"$HOME/chef/site-cookbooks"}

# This is teh template for the chef-solo configuration file,
# shipped to the virtual machines before execution.
CHEF_SOLO_CONFIG=$(cat <<EOF
log_level         :info
log_location      STDOUT
verbose_logging   nil
cookbook_path     ["/var/chef/cookbooks"]
role_path         "/var/chef/roles"
cache_type        "BasicFile"
cache_options({   :path => "/tmp/chef/cache/checksums", :skip_expires => true })
EOF
)


# This is the JSON specification use with chef-solo to
# configure the virtual machine. Users need to adjust this 
# file!
CHEF_ATTRIBUTES=$(cat <<EOF
{
  "run_list": [
    "recipe[empty]"
  ]
}
EOF
)

# Link a list of cookbooks from the Chef cookbook repository 
# the virtual machine containers cookbooks/ directory.
function __vm_chef_cookbook() {
  for _cookbook in $@
  do
    if [ -d $CHEF_COOKBOOKS/$_cookbook ] 
    then
      ln -v -s $CHEF_COOKBOOKS/$_cookbook $PWD/cookbooks/$_cookbook
    else
      _error "Cookbook '$_cookbook' not found!"
    fi
  done
}

function __vm_chef() {
  local _help=\
"Usage: vm config <command> [<sub-command>] [<args>]
Use Chef configuration management to provision a 
virtual machine instance.

Commands:
  add cookbook <name> [<name> ...]
    Define a list of cookbooks used to configure this
    virtual machine instance. They will be synced to 
    the virtual machine each time the configuration 
    process is executed.
  add role <path>
    Adds a role to apply to this virtual machine 
    instance. Roles will be synced each time the 
    configuration process is executed.
  solo
    Execute Chef in solo-mode inside the virtual machine
    instance using defined cookbooks and roles, as 
    well as the node description in 'chef_attributes.json'.
  client <server_hostname>
    Connect a virtual machine instance to an existing
    Chef server using the validation certificate and the
    configuration in the directory passed as argument."
  case "$1" in
    help) echo $_help ;;
    add)
      if ! [[ -d $PWD/cookbooks && -d $PWD/roles ]]; then
        echo -n "Create cookbooks/roles directories? (y/n): "
        read ans
        if [[ "$ans" == "y" ]]; then
          mkdir $PWD/cookbooks 
          mkdir $PWD/roles
        else
          return 
        fi
      fi
      case "$2" in
        cookbook) shift; shift; __vm_chef_cookbook $@ ;;
        role)
          if [[ -e $3 ]]; then
            local _name=$(basename $3)
            ln -v -s $3 $PWD/roles/$_name
          else
            echo "ERROR: '$3' isn't existing!"
          fi
          ;;
        *)
          echo "ERROR: cookbook|role are available parameters"
          ;;
      esac
      ;;
    solo)
      touch $PWD/chef.log # create the log file
      # Without at least on cookbook we cannot run!
      if [ ! -d $PWD/cookbooks -o -z $(find $PWD/cookbooks -maxdepth 1 -type l 2> /dev/null) ]; then
        _error  "No cookbook found!"
        return
      fi
      __vm_ssh "sudo mkdir -p -m 777 /var/chef/cookbooks"
      __vm_ssh 'sudo chmod 777 /var/chef'
      __vm_sync $PWD/cookbooks /var/chef >> $PWD/chef.log
      # Sync the roles if they exist
      if [[ -d $PWD/roles ]]; then
        __vm_ssh "[ ! -d /var/chef/roles ] && sudo mkdir -m 777 /var/chef/roles"
        __vm_sync $PWD/roles /var/chef/ >> $PWD/chef.log
      fi
      # Write the chef configuration file if not existing and upload it!
      if [[ ! -e $PWD/chef_config.rb ]]; then
        echo $CHEF_SOLO_CONFIG > $PWD/chef_config.rb
      fi
      __vm_put chef_config.rb /var/chef/config.rb
      if [[ ! -e $PWD/chef_attributes.json ]]; then
        echo $CHEF_ATTRIBUTES > $PWD/chef_attributes.json
        echo "INFO: No attributes definition to run chef-solo!"
        echo "Add cookbooks,roles and attributes to the file ./chef_attributes.json"
        return
      fi
      __vm_put chef_attributes.json /var/chef/attributes.json
      shift 2> /dev/null  
      __vm_ssh "cd /var/chef; sudo chef-solo -c config.rb -j attributes.json $@"
      ;;
    client)
      local _server=$2
      if [ -z $_server ]
      then
        _error "No Chef-Server instance defined!"
      else
        local _config=$KVM_VM_INSTANCES/$(__vm_fqdn $_server)
        _log "[__vm_chef] Reading Chef-Client configuration from '$_config'." 
        __vm_ssh 'sudo /etc/init.d/chef-client stop > /dev/null 2>&1'
        __vm_ssh 'sudo rm /etc/chef/client.pem > /dev/null 2>&1' 
        __vm_put $_config/chef_client.rb /tmp
        __vm_ssh 'sudo mv /tmp/chef_client.rb /etc/chef/client.rb'
        __vm_put $_config/chef/validation.pem /tmp
        __vm_ssh 'sudo mv /tmp/validation.pem /etc/chef/'
        sleep 1
        __vm_ssh 'sudo /etc/init.d/chef-client start'
        echo "Instance connected to Chef-Server '$_server'."
      fi
      ;;
    *) _error "Unknown command '$1'!"; echo $_help ;;
  esac
}

# Use Chef Knife configuration in the local directory to
# connect to the server.
function vknife() { knife $@ -c $PWD/chef/knife.rb; }

# --------------------------------------------------------------
##
## Interface all commands  
##

HELP=$(<<EOF
Usage: vm <command> [<sub-command>] [<args>]
Shell-function to manage clusters of local virtual
machines. (Version $_version)

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

Further information in the README. 
EOF
)


function vm() {
  local _command=$1
  if [ -z $_command ]; then 
    _command='status' 
  fi
  case "$_command" in
  status) 
    virsh list --all | awk '{gsub(/^ +| +$/,"")}1' |\
    tail -n +3 | cut -d ' ' -f2- 
    ;;
  network) shift; __vm_network "$@";;
  cd) shift; cd $KVM_VM_INSTANCES/$(__vm_fqdn $1) ;;
  login) shift; __vm_login "$@" ;; 
  template) shift; vmtemplate $@ ;;
  clone) shift; __vm_clone $@ ;;
  shadow) shift; _clone_shadow=true __vm_clone $@ ;;
  forward) shift; vmportforward $@ ;;
  help) echo $HELP ;;
  *)
    # the following commands can only be executed inside
    # a virtual machine container directory
    if $(__vm_container_directory); then
      case "$_command" in
      start) __vm_instance_start ;;
      stop) virsh shutdown $(vmid) ;;
      kill) virsh destroy $(vmid) ;;
      remove) __vm_instance_remove ;;
      image) shift; __vm_image $@ ;; 
      *) 
        # the following commands can only be execute when
        # the virtual machine is running
        if $(__vm_instance_running $(__vm_name)) ; then
          case "$_command" in
          put) shift; __vm_put $@ ;;
          exec) shift; __vm_ssh "$@" ;;
          get) shift; __vm_get $@ ;;
          sync) shift; __vm_sync $@ ;;
          fs) shift; __vm_fs $@ ;;
          config) shift; __vm_chef $@ ;;
          esac
        else
          _error "Virtual machine '$(__vm_name)' not running."
        fi
      ;; 
      esac
    else
      _error "Run this command inside a virtual machine container!" 
    fi
    ;;
  esac
}

echo "vm-functions loaded (Version $_version)"
echo "Run the 'vm help' for a command overview."


