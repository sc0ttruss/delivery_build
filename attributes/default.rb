
# the default location for files for our kitchen setup is in a local share
# ~/chef-kits/chef.  This is mounted to /mnt/share/chef on the target vm
# if you alreddy have these in an rpm repo, set source_files to false
# You can also replae file:// with https:// for remote repos.
default['delivery_build']['use_package_manager'] = false
default['delivery_build']['base_package_url'] = 'file:///mnt/share/chef'
# note the package "name" must match the name used by yum/rpm etc.
# get your package list here https://packages.chef.io/stable/el/7/
default['delivery_build']['packages']['chefdk'] = 'chefdk-0.12.0-1.el7.x86_64.rpm'
default['delivery_build']['packages']['delivery-cli'] ='delivery-cli-20160317163950-1.el6.x86_64.rpm'
default['delivery_build']['packages']['push-jobs-client'] ='push-jobs-client-1.3.4-1.el7.x86_64.rpm'
default['delivery_build']['packages']['runit'] ='runit-2.1.2-3.el7.centos.x86_64.rpm'
# add the delivery local user on the box
# but allow it to be skipped if already created
# in Linux based logins connected to ldap
default['delivery_build']['linux_user_based_ldap'] = false
default['delivery_build']['user'] = 'dbuild'
default['delivery_build']['uid'] = '7100'
default['delivery_build']['gid'] = 'users'
default['delivery_build']['home'] = '/var/opt/delivery/workspace'
# dbuild group needs to exist, as the build node will chown some directories
# with this group id, during pipeline execution
default['delivery_build']['group'] = 'dbuild'
# Load up the builder private ssh key and the chef delivery user's pem key
default['delivery_build']['base_filename_url'] = 'file:///mnt/share/chef/'

# Stuff related to credentials
default['delivery_build']['secrets_type'] = "vault"
default['delivery_build']['secrets_source'] = "delivery_secrets_vault"
default['delivery_build']['chef_username'] = "delivery"

# Delivery and SUpermarket URL's to retrieve their certificates
default['delivery_build']['url']['delivery'] = 'google.com'
default['delivery_build']['url']['supermarket'] = 'google.com'

# assume this node has alredy been bootstrapped
default['delivery_build']['url_chef']  = "#{Chef::Config.chef_server_url}"
