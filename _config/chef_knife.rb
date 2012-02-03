log_level                :info
log_location             STDOUT
node_name                'devops'
client_key               '/srv/vms/instances/lxcm01.devops.test/chef/devops.pem'
validation_client_name   'chef-validator'
chef_server_url          'http://10.1.1.3:4000'
cache_type               'BasicFile'
cache_options(           :path => '/tmp/chef/devops/checksums' )
cookbook_path            [ "~/chef/cookbooks","~/chef/site-cookbooks" ]
