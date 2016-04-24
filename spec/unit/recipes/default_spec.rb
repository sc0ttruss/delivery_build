#
# Cookbook Name:: delivery_build
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

# This is the current list of packages we expect to be installed
packages = {
  'chefdk' => 'chefdk-0.12.0-1.el7.x86_64.rpm',
  'delivery-cli' => 'delivery-cli-20160317163950-1.el6.x86_64.rpm',
  'push-jobs-client' => 'push-jobs-client-1.3.4-1.el7.x86_64.rpm',
  'runit' => 'runit-2.1.2-3.el7.centos.x86_64.rpm'
}

describe 'delivery_build::default' do

  #-------------------------------------------------------------------
  context 'When use_package_manager is false it' do
  #-------------------------------------------------------------------
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(log_level: :error) do |node|
        node.set['delivery_build']['use_package_manager'] = false
      end
      runner.converge(described_recipe)
    end

    packages.each do |pkg_name,pkg_filename|
      it "remote_file downloads chef-kit '#{pkg_name}' to /var/tmp" do
        expect(chef_run).to create_remote_file(/\/var\/tmp\/#{pkg_name}/).with_source("file:///mnt/share/chef/#{pkg_filename}")
      end
    end
    packages.each do |pkg_name,pkg_filename|
      it "installs package #{pkg_name} from /var/tmp" do
        expect(chef_run).to install_package(pkg_name).with_source("/var/tmp/#{pkg_filename}")
      end
    end
    it "installs package git from the OS repo" do
      expect(chef_run).to install_package("git").with_source(nil)
    end
  end

  #-------------------------------------------------------------------
  context 'When "use_package_manager" is true it' do
  #-------------------------------------------------------------------
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(log_level: :error) do |node|
        node.set['delivery_build']['use_package_manager'] = true
      end
      runner.converge(described_recipe)
    end

    packages.each do |pkg_name,pkg_filename|
      it "doesn't remote_file download #{pkg_name}" do
        expect(chef_run).not_to create_remote_file(/#{pkg_name}/)
      end
    end
    packages.each do |pkg_name,pkg_filename|
      it "installs package #{pkg_name} without overriding the source" do
        expect(chef_run).to install_package(pkg_name).with_source(nil)
      end
    end
    it "installs package git from the OS repo" do
      expect(chef_run).to install_package("git").with_source(nil)
    end
  end

end
