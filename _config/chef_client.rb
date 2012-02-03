log_level              :info
log_location           STDOUT
chef_server_url        'http://lxcm01.devops.test:4000'
validation_client_name "chef-validator"
validation_key         "/etc/chef/validation.pem"
client_key             "/etc/chef/client.pem"
file_cache_path        "/srv/chef/cache"
pid_file               "/var/run/chef/chef-client.pid"
