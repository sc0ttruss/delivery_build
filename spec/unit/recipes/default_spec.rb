#
# Cookbook Name:: delivery_build
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

# This is the current list of packages we expect to be installed
packages = {
  'chefdk' => 'chefdk-0.15.15-1.el7.x86_64.rpm',
  'push-jobs-client' => 'push-jobs-client-1.3.4-1.el7.x86_64.rpm',
  'runit' => 'runit-2.1.2-3.el7.centos.x86_64.rpm'
}

describe 'delivery_build::default' do

  #-------------------------------------------------------------------
  context 'When use_package_manager is false it' do
  #-------------------------------------------------------------------
    before(:each) do
      allow(ChefVault::Item).to receive(:load).
        with("delivery_secrets_vault","delivery_secrets").
        and_return({"builder_key"=>"an ssh key", "delivery_pem"=>"a delivery pem"})
      @runner = ChefSpec::ServerRunner.new(log_level: :error) do |node|
        node.set['delivery_build']['use_package_manager'] = false
        node.set['delivery_build']['base_package_url'] = 'http://myserver'
      end
      @runner.converge(described_recipe)
    end

    it "downloads the correct chef packages from http://myserver to /var/tmp" do
      packages.each do |pkg_name,pkg_filename|
        expect(@runner).to create_remote_file(/\/var\/tmp\/#{pkg_name}/).with_source("http://myserver/#{pkg_filename}")
      end
    end
    it "installs the chef packages from /var/tmp" do
      packages.each do |pkg_name,pkg_filename|
        expect(@runner).to install_package(pkg_name).with_source("/var/tmp/#{pkg_filename}")
      end
    end
    it "installs package git from the OS repo" do
      expect(@runner).to install_package("git").with_source(nil)
    end
  end

  #-------------------------------------------------------------------
  context 'When "use_package_manager" is true it' do
  #-------------------------------------------------------------------
    before(:each) do
      allow(ChefVault::Item).to receive(:load).
        with("delivery_secrets_vault","delivery_secrets").
        and_return({"builder_key"=>"an ssh key", "delivery_pem"=>"a delivery pem"})
      @runner = ChefSpec::ServerRunner.new(log_level: :error) do |node|
        node.set['delivery_build']['use_package_manager'] = true
        node.set['delivery_build']['base_package_url'] = 'http://myserver'
      end
      @runner.converge(described_recipe)
    end

    it "doesn't remote_file download any packages" do
      packages.each do |pkg_name,pkg_filename|
        expect(@runner).not_to create_remote_file(/#{pkg_name}/)
      end
    end
    it "installs the chef packages without overriding the source" do
      packages.each do |pkg_name,pkg_filename|
        expect(@runner).to install_package(pkg_name).with_source(nil)
      end
    end
    it "installs package git from the OS repo" do
      expect(@runner).to install_package("git").with_source(nil)
    end
  end
end
