# Virtual Machine Provisioning

## Chef Solo


All file relevant to the provisioning of a virtual machine with Chef Solo will be located in the virtual machine instance directory. Download a virtual machine template with pre-installed Chef client and start for example with host name _lxdev01_.

    $ vm template remote download debian64-6.0.4-chef-client-0.10.8.kvm.tgz
    $ vm clone debian64-6.0.4-chef-client-0.10.8 lxdev01

(Overwrite the environment variable **$CHEF_COOKBOOKS** with the path to your Chef repository unless the default `$HOME/chef/cookbooks/` is correct.) Select the list of cookbooks you want to deploy and add them one-by-one. All added cookbooks will be synced automatically to the virtual machine instance as soon as provisioning is executed.

    $ vm config add cookbook apt resolve ntp

You can change your cookbooks locally at any time. Any re-execution of the provisioning will run a differential sync to make all changes visible inside the virtual machine. Adjust the file `chef_attribtues.json` with the configuration you want to use for the virtual machine instance, e.g.:

    { 
      "run_list": [ 
        "recipe[apt]",
        "recipe[ntp]",
        "recipe[resolv]"
      ],
      "ntp": {
        "servers": [ "timeserver.gsi.de" ]
      },
      "resolv": {
        "nameserver": [ "10.1.1.1" ],
        "search": "devops.test gsi.de"
      }
    }

And finally execute Chef-Solo to configure the virtual machine with the command **config solo**. Each virtual machine keeps it own Chef configuration in its directory. Except of the `chef_attributes.json` file you can also adjust the `chef_config.rb` file. This file is also synced to the instance at each execution of the provisioning process. It is used to configure the _chef-client_ executed in the virtual machine. Looking into this file will show you where cookbooks and roles will be located and allows you to increase the logging level by setting `log_level :debug`.

The `cookbook/` and `roles/` directories contain links to the actual cookbooks and role files. Adding a role to your provision process is done by executing:

**vm config add role PATH**

## Chef Server

We call the Chef-server virtual machine instance for the development environment `lxcm01.devops.test` (for (L)inu(x) (c)onfiguration (m)anagement). Provisioning will be done using _chef-solo_:

We add a couple of dependency Chef cookbooks to the instance configuration. Adjust the Chef node description in `chef_attributes.json` like:

    { 
      "run_list": [ 
        "recipe[apt]",
        "recipe[ntp]",
        "recipe[chef::server]"
      ]
    }

Finally we execute Chef solo with:

    $ vm config solo
    [... SNIP ...]
    [Wed, 26 Oct 2011 14:40:06 +0200] INFO: Chef Run complete in 383.407762 seconds
    [Wed, 26 Oct 2011 14:40:06 +0200] INFO: Running report handlers
    [Wed, 26 Oct 2011 14:40:06 +0200] INFO: Report handlers complete

### Configure the Chef-Server

Installation and configuration will take some time, be patient. For my test-installations I'm just using the *devops* user account to gain administrative access to Chef. 

    $ vm exec sudo chmod a+r /etc/chef/webui.pem /etc/chef/validation.pem
    $ vm exec knife configure -i
    WARNING: No knife configuration file found
    Where should I put the config file? [~/.chef/knife.rb] 
    Please enter the chef server URL: [http://lxcm01.devops.gsi.de:4000] 
    Please enter a clientname for the new client: [devops] 
    Please enter the existing admin clientname: [chef-webui] 
    Please enter the location of the existing admin client's private key: [/etc/chef/webui.pem] 
    Please enter the validation clientname: [chef-validator] 
    Please enter the location of the validation key: [/etc/chef/validation.pem] 
    Please enter the path to a chef repository (or leave blank): 
    Creating initial API user...
    Created client[devops]
    Configuration file written to /home/devops/.chef/knife.rb

This creates the credentials for the devops user. Move them out of the virtual machine instance and store them to the container. Later they will be used to connect clients to this Chef-server instance.

    $ mkdir chef
    $ vm get /etc/chef/validation.pem chef/
    $ vm get .chef/devops.pem chef/
    $ cp /srv/vms/_config/chef_client.rb .

Copy the default `_config/chef-client.rb` configuration distributed with this scripts to the virtual machine instance directory. Finally create a script to define an alias to connect to your new virtual chef server *devops_env.sh*.

    # Use Chef Knife configuration in the local directory to
    # connect to the server.
    function kn() { knife $@ -c $PWD/chef/knife.rb; }

As you can see it uses a configuration file `chef/knife.rb`. Copy the default configuration from  `_config/chef_knife.rb` and adjust your cookbook path.

    $ cp /srv/vms/_config/chef_knife.rb chef/knife.rb
    $ source devops_env.sh

### Connect a Chef Client

Next step is to connect a couple of virtual machine instances as clients to the Chef-server.

    $ vm clone debian64-6.0.4-chef-client-0.10.8 lxb001
    $ vm config client lxcm01
    $ vm clone debian64-6.0.4-chef-client-0.10.8 lxb002
    $ vm config client lxcm01

List the nodes connected to the Chef-Server with:


    $ kn node list
    lxb001.devops.test
    lxb002.devops.test


