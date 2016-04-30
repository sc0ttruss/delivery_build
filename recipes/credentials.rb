#
# Cookbook Name:: delivery_build
# Recipe:: credentials
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


# Grab the secrets from a vault or data bag
case node['delivery_build']['secrets_type']
  when "vault"
    chef_gem 'chef-vault' do
      compile_time true
      action :install
    end
    require 'chef-vault'
    secrets = ChefVault::Item.load(node.delivery_build.secrets_source,"delivery_secrets")
  when "databag","data_bag"
    secrets = DataBagItem.load(node.delivery_build.secrets_source,"delivery_secrets")
  when "encrypted_databag","encrypted_data_bag"
    secrets = EncryptedDataBagItem.load(node.delivery_build.secrets_source,"delivery_secrets")
  when "local-files"
    delivery_pem_content = (File.read('/mnt/share/chef/delivery.pem' ))
    builder_key_content = (File.read('/mnt/share/chef/builder_key' ))
    user_content = "#{node.delivery_build.chef_username}"
    secrets = {delivery_pem: delivery_pem_content, builder_key: builder_key_content,  user: user_content}
  else
    Chef::Log.fatal "Must set attribute default['delivery_build']['secrets_type'] to vault, databag or encrypted_databag"
end

# This is the PEM generated when we registered the delivery user
# on the chef server. It must be an admin for the Chef Org

file "#{node.delivery_build.home}/etc/delivery.pem" do
  content secrets['delivery_pem']
  owner 'dbuild'
  group 'root'
  mode 00644
end

file "#{node.delivery_build.home}/.chef/delivery.pem" do
  content secrets['delivery_pem']
  owner 'dbuild'
  group 'root'
  mode 00644
end

# This is the builder SSH private key generated on the delivery server
# during creation of the enterprise. It's used to check out GIT repos
# and to remotely log into nodes for serverspec/inspec tests.

file "#{node.delivery_build.home}/etc/builder_key" do
  content secrets['builder_key']
  owner 'dbuild'
  group 'root'
  mode 00644
end

file "#{node.delivery_build.home}/.chef/builder_key" do
  content secrets['builder_key']
  owner 'dbuild'
  group 'root'
  mode 00644
end
