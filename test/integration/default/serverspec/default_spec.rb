require 'spec_helper'

packages = ['chefdk','delivery-cli','push-jobs-client','runit']

describe 'delivery_build::default' do

  packages.each do |pkg_name|
    describe package(pkg_name) do
      it {should be_installed}
    end
  end

  describe service("runsvdir-start") do
    it {should be_enabled}
    it {should be_running}
  end

end
