#
# Cookbook Name:: delivery_build
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Loop through packages (in recipe)
node['delivery_build']['packages'].each do |name,versioned_name|
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
end #Loop

package 'git' do
  action :install
end
#
# remote_file '/var/tmp/chefdk-0.12.0-1.el7.x86_64.rpm' do
#   source 'file:///mnt/share/chef/chefdk-0.12.0-1.el7.x86_64.rpm'
#   owner 'root'
#   group 'root'
#   only_if { node['delivery_build']['source_files']['exist'] }
# end
#
# remote_file '/var/tmp/delivery-cli-20160317163950-1.el6.x86_64.rpm' do
#   source 'file:///mnt/share/chef/delivery-cli-20160317163950-1.el6.x86_64.rpm'
#   owner 'root'
#   group 'root'
#   only_if { node['delivery_build']['source_files']['exist'] }
# end
#
# remote_file '/var/tmp/push-jobs-client-1.3.4-1.el7.x86_64.rpm' do
#   source 'file:///mnt/share/chef/push-jobs-client-1.3.4-1.el7.x86_64.rpm'
#   owner 'root'
#   group 'root'
#   only_if { node['delivery_build']['source_files']['exist'] }
# end
#
# remote_file '/var/tmp/runit-2.1.2-3.el7.centos.x86_64.rpm' do
#   source 'file:///mnt/share/chef/runit-2.1.2-3.el7.centos.x86_64.rpm'
#   owner 'root'
#   group 'root'
#   only_if { node['delivery_build']['source_files']['exist'] }
# end
#
# package 'chefdk' do
#   source '/var/tmp/chefdk-0.12.0-1.el7.x86_64.rpm'
#   action :install
#   only_if { node['delivery_build']['source_files']['exist'] }
# end
#
# package 'delvery-cli' do
#   source '/var/tmp/delivery-cli-20160317163950-1.el6.x86_64.rpm'
#   action :install
#   only_if { node['delivery_build']['source_files']['exist'] }
# end
#
# package 'opscode-push-jobs-client' do
#   source '/var/tmp/push-jobs-client-1.3.4-1.el7.x86_64.rpm'
#   action :install
#   only_if { node['delivery_build']['source_files']['exist'] }
# end
#
# package 'git' do
#   action :install
# end
#
# package 'runit' do
#   source '/var/tmp/runit-2.1.2-3.el7.centos.x86_64.rpm'
#   action :install
#   only_if { node['delivery_build']['source_files']['exist'] }
# end
#
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

%w(log env control).each do |dir|
  directory "/etc/sv/opscode-push-jobs-client/#{dir}" do
    mode '0755'
    owner 'root'
    group 'root'
    action :create
    recursive true
  end
end

%w(main config).each do |dir|
  directory "/etc/sv/opscode-push-jobs-client/log/#{dir}" do
    mode '0755'
    owner 'root'
    group 'root'
    action :create
    recursive true
  end
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

user 'dbuild' do
  comment 'User for delivery build node'
  uid '7100'
  gid 'users'
  home '/var/opt/delivery/workspace'
  shell '/bin/bash'
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

remote_file '/var/opt/delivery/workspace/etc/delivery.pem' do
  # source 'http://myfile'
  source 'file:///mnt/share/chef/delivery.pem'
  owner 'dbuild'
  group 'root'
  mode 00644
  # checksum 'abc123'
end

remote_file '/var/opt/delivery/workspace/.chef/delivery.pem' do
  # source 'http://myfile'
  source 'file:///mnt/share/chef/delivery.pem'
  owner 'dbuild'
  group 'root'
  mode 00644
  # checksum 'abc123'
end

# Copy the builder SSH private key generated on the delivery server
#  during creation of the enterprise to the following locations

remote_file '/var/opt/delivery/workspace/etc/builder_key' do
  # source 'http://myfile'
  source 'file:///mnt/share/chef/builder_key'
  owner 'dbuild'
  group 'root'
  mode 00644
  # checksum 'abc123'
end

remote_file '/var/opt/delivery/workspace/.chef/builder_key' do
  # source 'http://myfile'
  source 'file:///mnt/share/chef/builder_key'
  owner 'dbuild'
  group 'root'
  mode 00644
  # checksum 'abc123'
end
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

# Trust the Delivery and Supermarket SSL certificate

directory '/etc/chef/trusted_certs' do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  action :create
end

bash 'copy across the Delivery and Supermarket SSL certificates' do
  user 'root'
  cwd '/var/tmp'
  code <<-EOH
  openssl s_client -showcerts -connect google.co.uk:443 </dev/null 2> /dev/null| openssl x509 -outform PEM > /etc/chef/trusted_certs/delivery.myorg.chefdemo.net
  openssl s_client -showcerts -connect google.co.uk:443 </dev/null 2> /dev/null| openssl x509 -outform PEM > /etc/chef/trusted_certs/supermarket.myorg.chefdemo.net
  EOH
end

# Lay down delivery-cmd and git_ssh scripts

template '/var/opt/delivery/workspace/bin/delivery-cmd' do
  source 'delivery-cmd.erb'
  owner 'root'
  group 'root'
  mode 00755
end

template '/var/opt/delivery/workspace/bin/git_ssh' do
  source 'git_ssh.erb'
  owner 'root'
  group 'root'
  mode 00755
end

# Set /etc/chef permissions
# The dbuild user needs access to some stuff in /etc/chef
# which is normally only available to root

directory '/etc/chef' do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

file '/etc/chef/client.rb' do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

directory '/etc/chef/trusted_certs' do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

# Chef does not support recursive chmod, so we do it using bash

bash 'chmod all files in directory for dbuild user' do
  user 'root'
  cwd '/var/tmp'
  code <<-EOH
  chmod 644 /etc/chef/trusted_certs/*
  EOH
end
