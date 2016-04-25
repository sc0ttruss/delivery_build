require 'spec_helper'

describe 'delivery_build::credentials' do
  #-------------------------------------------------------------------
  # First we try with a ChefVault
  #-------------------------------------------------------------------
  context 'When "secrets_type" is "vault" and "secrets_source" is "delivery_secrets_vault" it' do
    before(:each) do
      allow(ChefVault::Item).to receive(:load).
        with("delivery_secrets_vault","delivery_secrets").
        and_return({"builder_key"=>"an ssh key", "delivery_pem"=>"a delivery pem"})
      @runner = ChefSpec::ServerRunner.new(log_level: :error) do |node|
        node.normal['delivery_build']['secrets_type'] = "vault"
        node.normal['delivery_build']['secrets_source'] = "delivery_secrets_vault"
      end
      @runner.converge(described_recipe)
    end

    it "writes the SSH keys out to the delivery workspace" do
      expect(@runner).to create_file('/var/opt/delivery/workspace/.chef/builder_key').with_content("an ssh key")
      expect(@runner).to create_file('/var/opt/delivery/workspace/etc/builder_key').with_content("an ssh key")
    end
    it "writes the delivery.pem out to the delivery workspace" do
      expect(@runner).to create_file('/var/opt/delivery/workspace/.chef/delivery.pem').with_content("a delivery pem")
      expect(@runner).to create_file('/var/opt/delivery/workspace/etc/delivery.pem').with_content("a delivery pem")
    end
  end


  #-------------------------------------------------------------------
  # Next we try with a data bag
  #-------------------------------------------------------------------
  context 'When "secrets_type" is "databag" and "secrets_source" is "delivery_secrets" it' do
    before(:each) do
      allow(Chef::DataBagItem).to receive(:load).
        with("delivery_secrets","delivery_secrets").
        and_return({"builder_key"=>"an ssh key", "delivery_pem"=>"a delivery pem"})
      @runner = ChefSpec::ServerRunner.new(log_level: :error) do |node|
        node.normal['delivery_build']['secrets_type'] = "databag"
        node.normal['delivery_build']['secrets_source'] = "delivery_secrets"
      end
      @runner.converge(described_recipe)
    end

    it "writes the SSH keys out to the delivery workspace" do
      expect(@runner).to create_file('/var/opt/delivery/workspace/.chef/builder_key').with_content("an ssh key")
      expect(@runner).to create_file('/var/opt/delivery/workspace/etc/builder_key').with_content("an ssh key")
    end
    it "writes the delivery.pem out to the delivery workspace" do
      expect(@runner).to create_file('/var/opt/delivery/workspace/.chef/delivery.pem').with_content("a delivery pem")
      expect(@runner).to create_file('/var/opt/delivery/workspace/etc/delivery.pem').with_content("a delivery pem")
    end
  end

  #-------------------------------------------------------------------
  # Next we try with an encrypted data bag
  #-------------------------------------------------------------------
  context 'When "secrets_type" is "encrypted_databag" and "secrets_source" is "delivery_secrets" it' do
    before(:each) do
      allow(Chef::EncryptedDataBagItem).to receive(:load).
        with("delivery_secrets","delivery_secrets").
        and_return({"builder_key"=>"an ssh key", "delivery_pem"=>"a delivery pem"})
      @runner = ChefSpec::ServerRunner.new(log_level: :error) do |node|
        node.normal['delivery_build']['secrets_type'] = "encrypted_databag"
        node.normal['delivery_build']['secrets_source'] = "delivery_secrets"
      end
      @runner.converge(described_recipe)
    end

    it "writes the SSH keys out to the delivery workspace" do
      expect(@runner).to create_file('/var/opt/delivery/workspace/.chef/builder_key').with_content("an ssh key")
      expect(@runner).to create_file('/var/opt/delivery/workspace/etc/builder_key').with_content("an ssh key")
    end
    it "writes the delivery.pem out to the delivery workspace" do
      expect(@runner).to create_file('/var/opt/delivery/workspace/.chef/delivery.pem').with_content("a delivery pem")
      expect(@runner).to create_file('/var/opt/delivery/workspace/etc/delivery.pem').with_content("a delivery pem")
    end
  end


end
