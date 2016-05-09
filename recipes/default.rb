#
# Cookbook Name:: delivery_build
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Loop through packages (in recipe)
node['delivery_build']['packages'].each do |name, versioned_name|
  unless node['delivery_build']['use_package_manager']
    remote_file "/var/tmp/#{versioned_name}" do
      source "#{node['delivery_build']['base_package_url']}/#{versioned_name}"
    end
  end
  package name do
    unless node['delivery_build']['use_package_manager']
      source "/var/tmp/#{versioned_name}"
    end
    action :install
  end
end # Loop

package 'git' do
  action :install
end

# this is required in case node is not already bootstrapped

directory '/etc/chef' do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  action :create
end

template '/etc/chef/push-jobs-client.rb' do
  source 'push-jobs-client.erb'
  # owner 'root'
  # group 'root'
  mode 00755
end

# Create a runit configuration to start Push Jobs daemon

%w(log/main env control).each do |dir|
  directory "/etc/sv/opscode-push-jobs-client/#{dir}" do
    mode '0755'
    owner 'root'
    group 'root'
    action :create
    recursive true
  end
end

directory "/var/log/opscode-push-jobs-client" do
  mode '0755'
  owner 'root'
  group 'root'
  recursive true
  action :create
end

file "/etc/sv/opscode-push-jobs-client/log/config" do
  mode '0644'
  owner 'root'
  group 'root'
  action :create
end

link "/var/log/opscode-push-jobs-client/config" do
  to "/etc/sv/opscode-push-jobs-client/log/config"
end

# Create a script /etc/sv/opscode-push-jobs-client/run with 755 permissions

template '/etc/sv/opscode-push-jobs-client/run' do
  source 'run.erb'
  # owner 'root'
  # group 'root'
  mode 00755
end

# Create a script /etc/sv/opscode-push-jobs-client/log/run with 755 permissions

template '/etc/sv/opscode-push-jobs-client/log/run' do
  source 'log_run.erb'
  # owner 'root'
  # group 'root'
  mode 00755
end

# Create a symlink in the init.d directory to sv

link '/etc/init.d/opscode-push-jobs-client' do
  to '/sbin/sv'
end

# Create a symlink for pushy in the service directory

link '/etc/service/opscode-push-jobs-client' do
  to '/etc/sv/opscode-push-jobs-client'
  action :create
end

# Create the dbuild user and workspace (home dir)

directory '/var/opt/delivery' do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  action :create
end

unless node['delivery_build']['linux_user_based_ldap']
  user node['delivery_build']['user'] do
    comment 'User for delivery build node'
    uid node['delivery_build']['uid']
    gid node['delivery_build']['gid']
    home node['delivery_build']['home']
    shell '/bin/bash'
  end
   group node['delivery_build']['group'] do
     members [node['delivery_build']['user']]
     action :create
   end
end

%w(bin etc lib).each do |dir|
  directory "/var/opt/delivery/workspace/#{dir}" do
    mode '0755'
    owner 'root'
    group 'root'
    action :create
    recursive true
  end
end

directory '/var/opt/delivery/workspace/.chef' do
  owner 'dbuild'
  # group 'dbuild'
  mode 00755
  recursive true
  action :create
end

file '/var/opt/delivery/workspace/etc/delivery-git-ssh-known-hosts' do
  owner 'root'
  group 'root'
  # mode 00755
  action :touch
end

# Lay down the builder credentials
include_recipe "delivery_build::credentials"
# Lay down the builder knife.rb/delivery.rb

template '/var/opt/delivery/workspace/etc/delivery.rb' do
  source 'delivery.rb.erb'
  owner 'dbuild'
  group 'root'
  mode 00644
end

template '/var/opt/delivery/workspace/.chef/delivery.rb' do
  source 'delivery.rb.erb'
  owner 'dbuild'
  group 'root'
  mode 00644
end

template '/var/opt/delivery/workspace/etc/knife.rb' do
  source 'knife.rb.erb'
  owner 'dbuild'
  group 'root'
  mode 00644
end

template '/var/opt/delivery/workspace/.chef/knife.rb' do
  source 'knife.rb.erb'
  owner 'dbuild'
  group 'root'
  mode 00644
end


# Trust the Delivery and Supermarket SSL certificate

directory '/etc/chef/trusted_certs' do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  action :create
end

# Grab all the required "TRUSTED" certs. These are mainly self signed certs
# andcerts which are signed using modern CA's that haven't made it into common
# Linux distros yet.

node['delivery_build']['url'].each do |_name, url|
  bash 'retreive the ssl certs for both servers' do
    user 'root'
    # cwd '/etc/chef/trusted_certs/'
    code <<-EOH
    # cd /etc/chef/trusted_certs/
    knife ssl fetch https://#{url}
    EOH
    # not_if { ::File.exist? "/etc/chef/trusted_certs/#{url}.crt" }
  end
end

# this is a brute force copy with no checks due to
# the entire cert chain is required every time

# note putting all the certs into the cacerts.pem for chefdk
# is a bit brute force, as really on the chef server
# certificate is required.
bash 'copy certificates to three locations' do
  user 'root'
  # cwd '/etc/chef/trusted_certs/'
  code <<-EOH
  cp /root/.chef/trusted_certs/*.crt /etc/chef/trusted_certs/
  cp /root/.chef/trusted_certs/*.crt /etc/pki/ca-trust/source/anchors/
  cat /root/.chef/trusted_certs/*.crt >> /opt/chefdk/embedded/ssl/certs/cacert.pem
  EOH
end

# Lay down delivery-cmd which gets executed by PUSHY when a job needs running
template '/var/opt/delivery/workspace/bin/delivery-cmd' do
  source 'delivery-cmd.erb'
  owner 'root'
  group 'root'
  mode 00755
end

# This is a wrapper around SSH to stop problems like untrusted host keys
# messing up git stuff
template '/var/opt/delivery/workspace/bin/git_ssh' do
  source 'git_ssh.erb'
  owner 'root'
  group 'root'
  mode 00755
end

# Make sure dbuild can read the chef client config
file '/etc/chef/client.rb' do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end
